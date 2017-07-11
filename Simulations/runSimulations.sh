#!/bin/bash

for timepoints in 5 10 25 50 100 250 500 1000; do
    for i in 1 2 3 4 5 6 7 8 9 10; do
        ananke simulation -d Simulation_${timepoints}_${i}.h5 -t ${timepoints} -r 100
	ananke cluster -i Simulation_${timepoints}_${i}.h5 -n 4 -l 0.001 -u 1 -s 0.001 -d sts
	ananke score_simulation -d Simulation_${timepoints}_${i}.h5 | grep 'AMI' >> AMI.txt
    done
done
