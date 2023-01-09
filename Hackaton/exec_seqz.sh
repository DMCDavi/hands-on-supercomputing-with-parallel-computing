#!/bin/sh

BEST_THREAD=$(awk 'BEGIN{best_time=-1; best_thread=""} {if(best_time == -1 || $3 <= best_time){best_time = $3; best_thread = $2;}} END{print best_thread}' omp)
BEST_PROCESS=$(awk 'BEGIN{best_time=-1; best_process=""} {if(best_time == -1 || $3 <= best_time){best_time = $3; best_process = $2;}} END{print best_process}' mpi)

#echo "Senha (Entradas) | Sequencial | OpenMP | MPI  | Híbrido | CUDA" >time_seqz
#echo "Senha (Entradas) | OpenMP | MPI  | Híbrido | CUDA" >speedup_seqz

for PASS in zzzzzzzzzz
do
    LENGTH=${#PASS}

    ./bruteForce $PASS >tmp_seq
    SEQUENTIAL_TIME=$(<tmp_seq)
    
    OMP_NUM_THREADS=$BEST_THREAD ./bruteForce-omp $PASS >tmp_omp
    mpirun -x MXM_LOG_LEVEL=error -np $BEST_PROCESS ./bruteForce-mpi $PASS 2>/dev/null >tmp_mpi
    OMP_NUM_THREADS=8 mpirun -x MXM_LOG_LEVEL=error -np 4 ./bruteForce-mpi+omp $PASS 2>/dev/null >tmp_mpi+omp
    ./bruteForce-cuda $PASS >tmp_cuda
        

    pr -m -t -s\  tmp_omp  tmp_mpi  tmp_mpi+omp  tmp_cuda  | awk -v pwd=$PASS -v pwd_len=$LENGTH -v seq=$SEQUENTIAL_TIME '{printf  "(%dz) %s     |     %d      |   %s | %s |    %s | %s\n", pwd_len, pwd, seq, $3, $6, $9, $12;}' >>time_seqz
    pr -m -t -s\  tmp_omp  tmp_mpi  tmp_mpi+omp  tmp_cuda  | awk -v pwd=$PASS -v pwd_len=$LENGTH -v seq=$SEQUENTIAL_TIME '{printf  "(%dz) %s     |   %1.2f | %1.2f |    %1.2f | %1.2f\n", pwd_len, pwd, (((seq)*1000)/(($3)*1000)), (((seq)*1000)/(($6)*1000)), (((seq)*1000)/(($9)*1000)), (((seq)*1000)/(($12)*1000));}' >>speedup_seqz
done
        
rm -f ./tmp*
