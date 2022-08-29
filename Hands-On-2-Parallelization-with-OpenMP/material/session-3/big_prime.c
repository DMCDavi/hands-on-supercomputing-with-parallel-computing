%%writefile big_prime.c
/*
File:           big_prime.c
Last changed:   20220303 11:35:00
Purpose:        Parallelize finding the biggest 128 bit prime number using openMP
Author:         Murilo Boratto - muriloboratto@uneb.br
Usage:
HowToCompile:   gcc big_prime.c -o big_prime -fopenmp -lm
HowToExecute:   OMP_NUM_THREADS=${num_threads} ./big_prime
                OMP_NUM_THREADS=4              ./big_prime
*/

#include <stdio.h>
#include <math.h>
#include <limits.h>
#include <omp.h>

typedef unsigned long long big_integer;
#define BIGGEST_INTEGER ULLONG_MAX
#define NUM_THREADS 2

int is_prime(big_integer n)
{
  int result;
  big_integer sq_root, i;

  result = (n % 2 != 0 || n == 2);

  if (result)
  {
    sq_root = sqrt(n);
    
    omp_set_num_threads(NUM_THREADS);
    #pragma omp parallel private(i)
    {
      int id = omp_get_thread_num();

      if(id == 0)
      {
        i = 3;
        while(result && i <= (big_integer)sq_root/NUM_THREADS){
          result = n % i != 0;
          i += 2;
        }
      }
      if(id == 1)
      {
        i = (big_integer)sq_root/NUM_THREADS;
        while(result && i <= 2*sq_root/NUM_THREADS){
          result = n % i != 0;
          i += 2;
        }
      }
    }
  }

  return result;
}

int main(int argc, char **argv)
{
  big_integer n;
  double t1, t2;
  t1 = omp_get_wtime();
  for (n = BIGGEST_INTEGER; !is_prime(n); n -= 2)
  {
  }
  t2 = omp_get_wtime();
  printf("Tempo de execução: %lf\n", t2-t1);
  printf("%llu\n", n);

  return 0;
}