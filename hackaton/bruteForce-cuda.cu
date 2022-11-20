#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <cuda.h>
#include <assert.h>

//97 to 122 use only lowercase letters
//65 to 90 use only capital letters
//48 to 57 use only numbers

#define START_CHAR 97
#define END_CHAR 122
#define MAXIMUM_PASSWORD 20
#define MAX_THREADS_PER_BLOCK 1024
#define BLOCKS_PER_SM 32

// Retorna erro, se houver, de uma função CUDA
inline cudaError_t checkCuda(cudaError_t result)
{
  if (result != cudaSuccess) {
    fprintf(stderr, "CUDA Runtime Error: %s\n", cudaGetErrorString(result));
    assert(result == cudaSuccess);
  }
  return result;
}

__device__ long long my_pow(long long x, int y) {
  long long res = 1;
  if (y == 0)
    return res;
  else
    return x * my_pow(x, y - 1);
}

// Calcula o tamanho de uma string
// Obs.: CUDA não tem suporte para a função strlen de string.h
__device__ int my_strlen(char *s) {
  int sum = 0;
  while (*s++) sum++;
  return sum;
}

__global__ void bruteForce(char * pass) {
  int pass_b26[MAXIMUM_PASSWORD];

  long long int pass_decimal = 0;
  int base = END_CHAR - START_CHAR + 2;

  int size = my_strlen(pass);;

  for (int i = 0; i < size; i++)
    pass_b26[i] = (int) pass[i] - START_CHAR + 1;

  for (int i = size - 1; i > -1; i--)
    pass_decimal += (long long int) pass_b26[i] * my_pow(base, i);

  long long int max = my_pow(base, size);
  char s[MAXIMUM_PASSWORD];
  // Calcula a iteração a partir da quantidade de threads vezes o id do bloco mais o id da thread
  long long int j = blockIdx.x * blockDim.x + threadIdx.x;

  // Realiza loop-stride para processar dados maiores que a quantidade de threads na GPU
  // Uma única thread processa mais de um dado
  while (j < max) {
    if (j == pass_decimal) {
      // printf("Found password!\n");
      int index = 0;

      // printf("Password in decimal base: %lli\n", j);
      while (j > 0) {
        s[index++] = 'a' + j % base - 1;
        j /= base;
      }
      s[index] = '\0';

      // printf("Found password: %s\n", s);
      break;
    }
    // Calcula o stride pela multiplicação entre a quantidade de blocos e threads 
    j += blockDim.x * gridDim.x;
  }
}

int main(int argc, char ** argv) {
  char *password;
  time_t t1, t2;
  double dif;

  // Aloca a senha para ser acessada tanto pela CPU quanto pela GPU
  checkCuda( cudaMallocManaged( & password, MAXIMUM_PASSWORD * sizeof(char)) );

  strcpy(password, argv[1]);

  int deviceId, numberOfSMs;
  checkCuda( cudaGetDevice( & deviceId) );
  // Pega a quantidade de SMs presentes na GPU
  checkCuda( cudaDeviceGetAttribute( & numberOfSMs, cudaDevAttrMultiProcessorCount, deviceId) );
  // Multiplica a quantidade de SMs pela quantidade de blocos presentes em cada um
  int number_of_blocks = numberOfSMs * BLOCKS_PER_SM;
  int threads_per_block = MAX_THREADS_PER_BLOCK;

  // printf("Try to broke the password: %s\n", password);

  time( & t1);
  bruteForce <<< number_of_blocks, threads_per_block >>> (password);
  checkCuda( cudaGetLastError() );
  checkCuda( cudaDeviceSynchronize() );
  time( & t2);

  dif = difftime(t2, t1);
  printf("B%dT%d;%1.2f\n", number_of_blocks, threads_per_block, dif);

  checkCuda( cudaFree(password) );

  return 0;
}