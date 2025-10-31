from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize
import numpy

ext_modules = [
    Extension(
        "Leb_mpi",
        ["./Leb_mpi.pyx"],
        extra_compile_args=['-O3'],
    )
]

setup(name="Leb_mpi",
      ext_modules=cythonize(ext_modules),
      include_dirs=[numpy.get_include()],
      )
