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

int is_prime(big_integer n)
{
  int result;
  big_integer sq_root, i;

  result = (n % 2 != 0 || n == 2);

  if (result)
  {
    sq_root = sqrt(n);
    
    omp_set_num_threads(4);
    // firstprivate é usado para variaveis que foram declaradas antes
    // sempre que usar a operação and, tem que usar o reduction com &
    #pragma omp parallel firstprivate(i) reduction(&:result)
    {
      i += 2 * omp_get_thread_num();
      big_integer increment = 2 * omp_get_num_threads();

      while (result && i <= sq_root){
        result = n % i != 0;
        i += increment;
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