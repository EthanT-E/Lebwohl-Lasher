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
