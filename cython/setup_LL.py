from distutils.core import setup
from Cython.Build import cythonize
import numpy

setup(name="cython_LL",
      ext_modules=cythonize("./Leb_cython.pyx"),
      include_dirs=[numpy.get_include()],
      )
