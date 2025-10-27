#!/bin/bash
# Standard for running is 1000 iterations, Size 20, reduced temperature of 0.9 and 0 as plot flag.
# The solution is ran 3 times and an average is taken

# Clears the timing_data folder for new data
rm ./data/timing_data/LL*
if test "$#" == 1; then
  for i in $(seq 1 3);do
    python $1 1000 20 0.65 0
  done
fi

if test "$#" == 2; then
  for i in $(seq 1 3);do
    python $1 1000 $2 0.65 0
  done
fi
mv ./LL* ./data/timing_data/ 

python ./timings_py.py ./data/timing_data/
