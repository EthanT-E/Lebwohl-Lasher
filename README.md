# Lebwohl-Lasher crystal model
Base upon code Provided by Prof Simon Hanna
## How to use
For run files and pure python programs 

` python ./<Python file dir> <iteration num> <size> <reduced temperature> <plot flag>`

iteration num = the number of Monte Carlo steps

size = the width of the grid (actual number of crystals is size<sup>2<sup>)

reduced temperature = temperature given from 0 - 2 

| plot flag | Description |
| --------- | ----------- |
| 0 | no plot of crystal grid |
| 1 | Energy plot of crystal grid |
| 2 | Angles plot of crystal grid |
| 3 | Black plot of crystal grid |

| Program Directory | Description
|--------------------|------------|
|./serial/LebwohlLasher.py | Base serial code|
|./numba/Leb_numba.py | Numba code |
|./numba/Leb_vec.py | Numba with vectorization |
|./vectorization/NumVec.py | Numpy vectorization |

For cython please enter the cython folder and build setup file as shown below:

` python ./<setup_file> build_ext -fi`

Then run same as above:

` python ./<Run file> <iteration num> <size> <reduced temperature> <plot flag>`
| Program | setup file |
| --------- | --------- |
| ./run_cython.py | ./setup_LL.py |
| ./run_para.py | ./setup_para.py |
