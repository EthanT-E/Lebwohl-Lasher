from distutils.core import setup
from Cython.Build import cythonize

setup(name="cython_LL",
      ext_modules=cythonize("./Leb_cython.pyx"))
