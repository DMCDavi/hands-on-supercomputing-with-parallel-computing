#!/bin/sh

#SBATCH --job-name=552980                     # Job name
#SBATCH --nodes=1                              # Run all processes on 2 nodes
#SBATCH --partition=gpulongc                   # Partition OGBON
#SBATCH --output=out_%j.log                    # Standard output and error log
#SBATCH --ntasks-per-node=1                    # 1 job per node
#SBATCH --account=externos                   # Account of the group

################################################
# 0. COMPILATION + PERMISSIONS  TO EXECUTE     #
################################################
gcc bruteForce.c -o bruteForce -std=c99 -O3
gcc bruteForce-omp.c -o bruteForce-omp -fopenmp -std=c99 -O3
mpicc bruteForce-mpi.c -o bruteForce-mpi -fopenmp -std=c99 -O3
# mpicc bruteForce-mpi+omp.c -o bruteForce-mpi+omp -fopenmp -std=c99 -O3
# nvcc bruteForce-cuda.cu -o bruteForce-cuda -O3

chmod +x bruteForce
chmod +x bruteForce-omp
chmod +x bruteForce-mpi
# chmod +x bruteForce-mpi+omp
# chmod +x bruteForce-cuda


################################################
# 1. EXECUTION                                 #
################################################
PASS=$1

./bruteForce $PASS > seq

echo "num_threads;time" > omp

for i in 1 2 4 8 16 32 64 128 256 512
do
OMP_NUM_THREADS=$i ./bruteForce-omp $PASS >> omp
done

echo "num_process;time" > mpi

for i in 1 2 4 8 16 32
do
mpirun -x MXM_LOG_LEVEL=error -np $i --allow-run-as-root ./bruteForce-mpi $PASS 2>/dev/null >> mpi
done