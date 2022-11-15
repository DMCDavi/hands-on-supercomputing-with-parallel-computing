#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <cuda.h>

//97 to 122 use only lowercase letters
//65 to 90 use only capital letters
//48 to 57 use only numbers

#define START_CHAR 97
#define END_CHAR 122
#define MAXIMUM_PASSWORD 20
#define MAX_THREADS_PER_BLOCK 1024

long long my_pow(long long x, int y)
{
  long long res = 1;
  if (y==0)
    return res;
  else
    return x * my_pow(x, y-1);
}

__global__ void bruteForce_LOOP(char *sc, long long int max, long long int pass_decimal, int base){
  long long int j = threadIdx.x * blockIdx.x;
  
  if(j<max){
    
    if(j == pass_decimal){
      int index = 0;

      while(j > 0){
        sc[index++] = 'a' + j%base-1;
        j /= base;
      }
      sc[index] = '\0';
      
      return;
   
    }
}

}


void bruteForce(char *pass) 
{
  char force[MAXIMUM_PASSWORD];
  int palavra[MAXIMUM_PASSWORD];
  int pass_b26[MAXIMUM_PASSWORD];

  
  long long int pass_decimal = 0;
  int base = END_CHAR - START_CHAR + 2;

  int size = strlen(pass);

  for(int i = 0; i < MAXIMUM_PASSWORD; i++)
    force[i] = '\0';

  printf("Try to broke the password: %s\n", pass);

  for(int i = 0; i < size; i++)
    pass_b26[i] = (int) pass[i] - START_CHAR + 1; 

  for(int i = size - 1; i > -1; i--)
    pass_decimal += (long long int) pass_b26[i] * my_pow(base, i);

  long long int max = my_pow(base, size);
 

  int NUMBER_OF_BLOCKS = max/MAX_THREADS_PER_BLOCK + 1;
  int NUMBER_OF_THREADS_PER_BLOCK = MAX_THREADS_PER_BLOCK;
printf("%d\n", NUMBER_OF_BLOCKS);
printf("%d\n", NUMBER_OF_THREADS_PER_BLOCK);
printf("%lld\n", max);
printf("%lld\n", pass_decimal);
printf("%d\n", base);

char *sc;
  cudaMallocManaged( & sc, sizeof(char) * MAXIMUM_PASSWORD);

  bruteForce_LOOP<<<NUMBER_OF_BLOCKS, NUMBER_OF_THREADS_PER_BLOCK>>>(sc, max, pass_decimal, base);
  cudaDeviceSynchronize();
  printf("Found password!\n");
  printf("Found password: %s\n", sc);

  cudaFree(sc);
}

int main(int argc, char **argv) 
{
  char password[MAXIMUM_PASSWORD];

  strcpy(password, argv[1]);
  time_t t1, t2;
  double dif;

  
  time (&t1);
    bruteForce(password);
  time (&t2);

  dif = difftime (t2, t1);

  printf("\n%1.2f seconds\n", dif);

  return 0;
}