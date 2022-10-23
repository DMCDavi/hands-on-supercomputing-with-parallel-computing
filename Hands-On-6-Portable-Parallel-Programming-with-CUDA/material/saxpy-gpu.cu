/****************************************************************************80
*  Code: 
*   saxpy-gpu.cu
*
*  Purpose:
*   Implements in C the simple SAXPY stands for Single-Precision with GPU.
*
*  Modified:
*   May 08 2022 17:28 
*
*  Author:
*    Murilo Boratto  < muriloboratto 'at' fieb.org.br >
*
*  HowtoCompile:
*    gcc saxpy-gpu.cu -o saxpy-gpu
*   
*  HowtoExecute:
*    ./saxpy-gpu <size>
*    ./saxpy-gpu  10
*
*******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>

__global__ void saxpy(int n, float *x, float *y) {
  int i = threadIdx.x;
  if(i < n)
  y[i] = x[i] + y[i];
}

void printVector(float *vector, int n){

for (int i=0; i < n ; ++i)
 printf("%1.0f\t", vector[i]);

 printf("\n\n");

}

void generateVector(float *vector, int n){

for (int i=0; i < n ; ++i)
 vector[i] = i + 1;

}

int main(int argc, char *argv[]){

  int n = atoi(argv[1]);   
  float *x,*y;
  float *xd, *yd;

  x = (float*) malloc(sizeof(float) * n);
  y = (float*) malloc(sizeof(float) * n);

  cudaMalloc( (void**)&xd, sizeof(float) * n );
  cudaMalloc( (void**)&yd, sizeof(float) * n );
 
  generateVector(x, n);
  printVector(x, n);

  generateVector(y, n);
  printVector(y, n);

  cudaMemcpy(xd, x, sizeof(float) * n, cudaMemcpyHostToDevice);
  cudaMemcpy(yd, y, sizeof(float) * n, cudaMemcpyHostToDevice);

  int NUMBER_OF_BLOCKS = 1;
  int NUMBER_OF_THREADS_PER_BLOCK = n;

  saxpy<<< NUMBER_OF_BLOCKS, NUMBER_OF_THREADS_PER_BLOCK >>>(n, xd, yd);

  cudaDeviceSynchronize();

  cudaMemcpy(y, yd, sizeof(float) * (n), cudaMemcpyDeviceToHost);

  printVector(y, n);
 
  free(x);
  free(y);

  cudaFree(xd);
  cudaFree(yd);

  return 0;

}

