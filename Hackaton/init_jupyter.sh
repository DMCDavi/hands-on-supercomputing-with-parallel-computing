#!/bin/sh

module load openmpi/4.1.1-cuda-11.6-ofed-5.4
module load anaconda3/2020.07
jupyter lab --port=8559
