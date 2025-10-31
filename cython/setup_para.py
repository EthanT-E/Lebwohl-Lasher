from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize
import numpy

ext_modules = [
    Extension(
        "Leb_para",
        ["./Leb_para.pyx"],
        extra_compile_args=['-fopenmp', '-O3'],
        extra_link_args=['-fopenmp'],
    )
]

setup(name="Leb_para",
      ext_modules=cythonize(ext_modules),
      include_dirs=[numpy.get_include()],
      )
