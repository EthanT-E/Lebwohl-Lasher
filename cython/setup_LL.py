from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize
import numpy

ext_modules = [
    Extension(
        "Leb_cython",
        ["./Leb_cython.pyx"],
        extra_compile_args=['-O3']
    )
]
setup(name="Leb_cython",
      ext_modules=cythonize(ext_modules),
      include_dirs=[numpy.get_include()],
      )
