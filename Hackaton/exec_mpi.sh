#!/bin/sh

PASS=$1

#>mpi
>mpi+omp

#for i in 1 2 4 8 16 32
#do
#  mpirun -x MXM_LOG_LEVEL=error -np $i --allow-run-as-root ./bruteForce-mpi $PASS 2>/dev/null >> mpi
#done

BEST_THREAD=$(awk 'BEGIN{best_time=-1; best_thread=""} {if(best_time == -1 || $3 <= best_time){best_time = $3; best_thread = $2;}} END{print best_thread}' omp)
BEST_PROCESS=$(awk 'BEGIN{best_time=-1; best_process=""} {if(best_time == -1 || $3 <= best_time){best_time = $3; best_process = $2;}} END{print best_process}' mpi)

for p in 2 4 8 16 32
do
  THREAD_SAMPLES=0
  for t in $((BEST_THREAD/8)) $((BEST_THREAD/4)) $((BEST_THREAD/2)) $((BEST_THREAD)) $((BEST_THREAD*2)) $((BEST_THREAD*4))
  do
    if [ $((p*t)) -lt 4096 ]; then
        OMP_NUM_THREADS=$t mpirun -x MXM_LOG_LEVEL=error -np $p --allow-run-as-root ./bruteForce-mpi+omp $PASS 2>/dev/null >> mpi+omp
    fi
  done
done
