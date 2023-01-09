#!/bin/sh

#SBATCH --job-name=OMP_CUDA                    # Job name
#SBATCH --nodes=1                             # Run all processes on 2 nodes
#SBATCH --partition=gpushortc                  # Partition OGBON
#SBATCH --output=out_%j.log                    # Standard output and error log
#SBATCH --ntasks-per-node=32                   # 1 job per node
#SBATCH --account=treinamento                  # Account of the group

PASS=$1

./bruteForce $PASS > seq

#>omp
#for i in 1 2 4 8 16 32 64 128 256 512 1024 2048
#do
#  OMP_NUM_THREADS=$i ./bruteForce-omp $PASS >> omp
#done

./bruteForce-cuda $PASS > cuda
