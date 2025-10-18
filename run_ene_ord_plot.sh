#!/bin/bash

# inputs should be EXEC_PATH then DATA_PATH

rm LL*

python $1 1000 20 0.65 0

python ./plotter.py ./LL*
