import cython
from libc.math cimport cos, sin
import numpy as np
cimport numpy as cnp

cpdef double one_energy(double[:,:] arr, int ix, int iy,int nmax):
    cdef:
        double en = 0, ang
        int ixp = (ix+1)%nmax
        int ixm = (ix-1)%nmax
        int iyp = (iy+1)%nmax
        int iym = (iy-1)%nmax
        cnp.ndarray[dtype] 

    ang = arr[ix,iy] - arr[ixp,iy]
    en += 0.5*(1-3*(cos(ang)*cos(ang)))
    ang = arr[ix,iy] - arr[ixm,iy]
    en += 0.5*(1-3*(cos(ang)*cos(ang)))
    ang = arr[ix,iy] - arr[ix,iyp]
    en += 0.5*(1-3*(cos(ang)*cos(ang)))
    ang = arr[ix,iy] - arr[ix,iym]
    en += 0.5*(1-3*(cos(ang)*cos(ang)))

    return en

cpdef double all_energy(double[:,:] arr, int nmax):
    """
    Arguments:
          arr (float(nmax,nmax)) = array that contains lattice data;
      nmax (int) = side length of square lattice.
    Description:
      Function to compute the energy of the entire lattice. Output
      is in reduced units (U/epsilon).
        Returns:
          enall (float) = reduced energy of lattice.
    """
    cdef double enall = 0.0 #cdefing this doesn't impact the performance tbh
    cdef int i,j
    for i in range(nmax):
        for j in range(nmax):
            enall += one_energy(arr, i, j, nmax)
    return enall

cpdef double get_order(double[:,:] arr, int nmax):
    """
    Arguments:
          arr (float(nmax,nmax)) = array that contains lattice data;
      nmax (int) = side length of square lattice.
    Description:
      Function to calculate the order parameter of a lattice
      using the Q tensor approach, as in equation (3) of the
      project notes.  Function returns S_lattice = max(eigenvalues(Q_ab)).
        Returns:
          max(eigenvalues(Qab)) (float) = order parameter for lattice.
    """
    cdef cnp.ndarray[dtype=cnp.float64_t,ndim=2] Qab = np.zeros((3, 3),dtype=np.float64)
    cdef cnp.ndarray[dtype=cnp.float64_t,ndim=2] delta = np.eye(3, 3,dtype=np.float64)
    cdef int a,b,i,j
    #
    # Generate a 3D unit vector for each cell (i,j) and
    # put it in a (3,i,j) array.
    #
    cdef cnp.ndarray[dtype=cnp.float64_t,ndim=3] lab = np.vstack((np.cos(arr), np.sin(arr), np.zeros_like(arr))
                    ).reshape(3, nmax, nmax)
    for a in range(3):
        for b in range(3):
            for i in range(nmax):
                for j in range(nmax):
                    Qab[a, b] += 3*lab[a, i, j]*lab[b, i, j] - delta[a, b]
    Qab = Qab/(2*nmax*nmax)
    eigenvalues, eigenvectors = np.linalg.eig(Qab)
    return eigenvalues.max()

cpdef double MC_step(double[:,:] arr,double Ts,int nmax):
    """
    Arguments:
          arr (float(nmax,nmax)) = array that contains lattice data;
          Ts (float) = reduced temperature (range 0 to 2);
      nmax (int) = side length of square lattice.
    Description:
      Function to perform one MC step, which consists of an average
      of 1 attempted change per lattice site.  Working with reduced
      temperature Ts = kT/epsilon.  Function returns the acceptance
      ratio for information.  This is the fraction of attempted changes
      that are successful.  Generally aim to keep this around 0.5 for
      efficient simulation.
        Returns:
          accept/(nmax**2) (float) = acceptance ratio for current MCS.
    """
    #
    # Pre-compute some random numbers.  This is faster than
    # using lots of individual calls.  "scale" sets the width
    # of the distribution for the angle changes - increases
    # with temperature.
    cdef:
        double scale = 0.1+Ts
        int accept = 0
        cnp.ndarray[dtype=cnp.int64_t,ndim=2] xran = np.random.randint(0, high=nmax, size=(nmax, nmax),dtype=np.int64)
        cnp.ndarray[dtype=cnp.int64_t,ndim=2] yran = np.random.randint(0, high=nmax, size=(nmax, nmax), dtype=np.int64)
        cnp.ndarray[dtype=cnp.float64_t,ndim=2] aran = np.random.normal(scale=scale, size=(nmax, nmax))
        int i,j,ix,iy
        double ang, en0, en1, boltz
    for i in range(nmax):
        for j in range(nmax):
            ix = xran[i, j]
            iy = yran[i, j]
            ang = aran[i, j]
            en0 = one_energy(arr, ix, iy, nmax)
            arr[ix, iy] += ang
            en1 = one_energy(arr, ix, iy, nmax)
            if en1 <= en0:
                accept += 1
            else:
                # Now apply the Monte Carlo test - compare
                # exp( -(E_new - E_old) / T* ) >= rand(0,1)
                boltz = np.exp(-(en1 - en0) / Ts)

                if boltz >= np.random.uniform(0.0, 1.0):
                    accept += 1
                else:
                    arr[ix, iy] -= ang
    return accept/(nmax*nmax)
