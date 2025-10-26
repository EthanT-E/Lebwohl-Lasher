from libc.math cimport cos, sin
import numpy as np

def one_energy(double[:,:] arr, int ix, int iy,int nmax):
    cdef:
        double en = 0, ang
        int ixp = (ix+1)%nmax
        int ixm = (ix-1)%nmax
        int iyp = (iy+1)%nmax
        int iym = (iy-1)%nmax

    ang = arr[ix,iy] - arr[ixp,iy]
    en += 0.5*(1-3*(cos(ang)*cos(ang)))
    ang = arr[ix,iy] - arr[ixm,iy]
    en += 0.5*(1-3*(cos(ang)*cos(ang)))
    ang = arr[ix,iy] - arr[ix,iyp]
    en += 0.5*(1-3*(cos(ang)*cos(ang)))
    ang = arr[ix,iy] - arr[ix,iym]
    en += 0.5*(1-3*(cos(ang)*cos(ang)))

    return en

def all_energy(arr:np.ndarray, nmax:int) -> float:
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
    enall = 0.0 #cdefing this doesn't impact the performance tbh
    for i in range(nmax):
        for j in range(nmax):
            enall += one_energy(arr, i, j, nmax)
    return enall

def get_order(arr:np.ndarray, nmax:int) -> float:
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
    Qab = np.zeros((3, 3))
    delta = np.eye(3, 3)
    #
    # Generate a 3D unit vector for each cell (i,j) and
    # put it in a (3,i,j) array.
    #
    lab = np.vstack((np.cos(arr), np.sin(arr), np.zeros_like(arr))
                    ).reshape(3, nmax, nmax)
    for a in range(3):
        for b in range(3):
            for i in range(nmax):
                for j in range(nmax):
                    Qab[a, b] += 3*lab[a, i, j]*lab[b, i, j] - delta[a, b]
    Qab = Qab/(2*nmax*nmax)
    eigenvalues, eigenvectors = np.linalg.eig(Qab)
    return eigenvalues.max()
