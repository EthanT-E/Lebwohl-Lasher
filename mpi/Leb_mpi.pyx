import cython
from libc.math cimport cos, sin, exp
from libc.stdio cimport printf
import numpy as np
cimport numpy as cnp
from mpi4py import MPI

cpdef double[:,:] initdat(int nmax,int MPI_size):
    """
    Arguments:
      nmax (int) = size of lattice to create (nmax,nmax).
    Description:
      Function to create and initialise the main data array that holds
      the lattice.  Will return a square lattice (size nmax x nmax)
          initialised with random orientations in the range [0,2pi].
        Returns:
          arr (float(nmax,nmax)) = array to hold lattice.
    """
    cdef int width = nmax//MPI_size
    cdef cnp.ndarray[dtype=cnp.float64_t,ndim=2] arr = np.random.random_sample((nmax, width))*2.0*np.pi
    return arr

cpdef double one_energy_whole_lattice(double[:,:] arr, int ix, int iy,int nmax):
    cdef:
        double en = 0, ang
        int ixp = (ix +1)%nmax# might remove the %task_width
        int ixm = (ix -1)%nmax# might remove the %task_width
        int iyp = (iy+1)%nmax
        int iym = (iy-1)%nmax
        double cos_ang = 0

    ang = arr[iy,ix] - arr[iyp,ix]
    cos_ang = cos(ang)
    en += 0.5*(1-3*(cos_ang**2))
    ang = arr[iy,ix] - arr[iym,ix]
    cos_ang = cos(ang)
    en += 0.5*(1-3*(cos_ang**2))
    ang = arr[iy,ix] - arr[iy,ixp]
    cos_ang = cos(ang)
    en += 0.5*(1-3*(cos_ang**2))
    ang = arr[iy,ix] - arr[iy,ixm]
    cos_ang = cos(ang)
    en += 0.5*(1-3*(cos_ang**2))

    return en
cpdef double one_energy(double[:,:] arr, int ix, int iy,int nmax,int task_width,double[:] left_col,double[:] right_col):
    cdef:
        double en = 0, ang
        int iyp = (ix +1)%task_width# might remove the %task_width
        int iym = (ix -1)%task_width# might remove the %task_width
        int ixp = (iy+1)%nmax
        int ixm = (iy-1)%nmax
        double cos_ang = 0

    ang = arr[ix,iy] - arr[ixp,iy]
    cos_ang = cos(ang)
    en += 0.5*(1-3*(cos_ang**2))
    ang = arr[ix,iy] - arr[ixm,iy]
    cos_ang = cos(ang)
    en += 0.5*(1-3*(cos_ang**2))
    if (ix == task_width -1):
        ang = arr[ix,iy] - right_col[iy]
    else:
        ang = arr[ix,iy] - arr[ix,iyp]
    cos_ang = cos(ang)
    en += 0.5*(1-3*(cos_ang**2))
    if (ix == 0):
        ang = arr[ix,iy] - left_col[iy]
    else:
        ang = arr[ix,iy] - arr[ix,iym]
    cos_ang = cos(ang)
    en += 0.5*(1-3*(cos_ang**2))

    return en

cpdef double all_energy(double[:,:] arr, int nmax):
    """
    Arguments:
          arr (float(nmax,nmax)) = array that contains lattice data;
        nmax (int) = side length of square lattice.
        left_col(double(nmax)) the crystals to the left of arr
        right_col(double(nmax)) the crystals to the right of arr

    Description:
      Function to compute the energy of the entire lattice. Output
      is in reduced units (U/epsilon).
        Returns:
          enall (float) = reduced energy of lattice.
    """
    cdef double enall = 0.0 #cdefing this doesn't impact the performance tbh
    cdef int x,y
    for x in range(nmax):
        for y in range(nmax):
            enall += one_energy_whole_lattice(arr, x, y, nmax)
    return enall

cpdef double get_order(double[:,:] arr, int nmax):# MPIthis !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
# 
cpdef double MC_step(double[:,:] arr,double Ts,int nmax,int task_width,double[:] left_col,double[:] right_col):
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
        cnp.ndarray[dtype=cnp.int64_t,ndim=2] xran = np.random.randint(0, high=nmax, size=(nmax, task_width),dtype=np.int64)
        cnp.ndarray[dtype=cnp.int64_t,ndim=2] yran = np.random.randint(0, high=task_width, size=(nmax, task_width), dtype=np.int64)
        cnp.ndarray[dtype=cnp.float64_t,ndim=2] aran = np.random.normal(scale=scale, size=(nmax, task_width))
        double[:,:] boltzman_arr = np.random.uniform(0.0, 1.0,size=(nmax,nmax))
        int i,j,ix,iy
        double ang, en0, en1, boltz
    for i in range(task_width):
        for j in range(nmax):
            ix = xran[j, i]
            iy = yran[j, i]
            ang = aran[j, i]
            en0 = one_energy(arr, ix, iy, nmax,task_width,left_col,right_col)
            arr[ix, iy] += ang
            en1 = one_energy(arr, ix, iy, nmax,task_width,left_col,right_col)
            if en1 <= en0:
                accept += 1
            else:
                # Now apply the Monte Carlo test - compare
                # exp( -(E_new - E_old) / T* ) >= rand(0,1)
                boltz = exp(-(en1 - en0) / Ts)

                if boltz >= boltzman_arr[i,j]:
                    accept += 1
                else:
                    arr[ix, iy] -= ang
    return accept/(nmax*task_width)
#         
# # cpdef run(double[:,:] lattice,int nsteps,int nmax,double temp):
# #     '''
# #     Parameters:
# #         lattice double(nmax,nmax):
# #             premade lattice of crystal grid to be scattered amoung threads
# #         nsteps int:
# #             number of monte carlo steps
# #         nmax int:
# #             width of square of the crystal grid
# #         double temp:
# #             reduced tempurature of simulation
# #     return:
# #         the Lattice for printing
# #     '''
# #     COMM = MPI.COMM_WORLD
# #     cdef:
# #         int rank = COMM.Get_rank()
# #         int size = COMM.Get_size()
# #         int[:] arr_shape
# #         int[:] shape
# #     if (nmax%size != 0):
# #         #if the size of the grid can't be evenly split between tasks then abort
# #         printf("nmax must be divisable by the number of tasks\n")
# #         comm.abort()
# #     cdef:
# #         int task_grid_size = nmax//size
# #         cnp.ndarray[dtype=cnp.float64_t,ndim=2] task_lattice = np.zeros((nmax,task_grid_size),dtype=np.float64)
# #     COMM.Scatter(lattice,task_lattice,root=0)
# #     if rank == 0:
# #         for i in range(0,task_grid_size):
# #             printf("%f\n",task_lattice[1,i])
