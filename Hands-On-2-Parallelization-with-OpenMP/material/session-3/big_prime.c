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

typedef unsigned long long big_integer;
#define BIGGEST_INTEGER ULLONG_MAX

int is_prime(big_integer n)
{
  int result;
  big_integer sq_root;

  result = (n % 2 != 0 || n == 2);

  if (result)
  {
    sq_root = sqrt(n);

	// Quando é redução a paralelização é com reduction.
	// Usar -pg para gerar relatorio na execução e gprof para converter o relatorio
	#pragma omp parallel for private(i)
    for (big_integer i = 3; result && i <= sq_root; i += 2)
      result = n % i != 0;
  }

  return result;
}

int main(int argc, char **argv)
{
  big_integer n;

  for (n = BIGGEST_INTEGER; !is_prime(n); n -= 2)
  {
  }

  printf("%llu\n", n);

  return 0;
}
