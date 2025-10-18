#!/bin/bash

rm ./data/average_order/LL*
for i in {0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1,1.1,1.2,1.3,1.4,1.5,1.6};do
  python $1 1000 20 $i 0
done
mv LL* ./data/average_order/
python avgPlotter.py "./data/average_order/" "Order"
