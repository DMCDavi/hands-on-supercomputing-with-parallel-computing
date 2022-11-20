#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <mpi.h>
#include <omp.h>

//97 to 122 use only lowercase letters
//65 to 90 use only capital letters
//48 to 57 use only numbers

#define START_CHAR 97
#define END_CHAR 122
#define MAXIMUM_PASSWORD 20
#define MASTER 0

time_t t1, t2;

long long my_pow(long long x, int y)
{
  long long res = 1;
  if (y==0)
    return res;
  else
    return x * my_pow(x, y-1);
}

void bruteForce(char *pass, int base, int size, long long int min, long long int max) 
{
  int pass_b26[MAXIMUM_PASSWORD];
    
  long long int j;
  long long int pass_decimal = 0;

  for(int i = 0; i < size; i++)
    pass_b26[i] = (int) pass[i] - START_CHAR + 1; 

  for(int i = size - 1; i > -1; i--)
    pass_decimal += (long long int) pass_b26[i] * my_pow(base, i);

  char s[MAXIMUM_PASSWORD];

  #pragma omp parallel for private(j)
  for(j = min; j < max; j++){
    if(j == pass_decimal){
      // printf("Found password!\n");
      int index = 0;

      // printf("Password in decimal base: %lli\n", j);
      while(j > 0){
        s[index++] = 'a' + j%base-1;
        j /= base;
      }
      s[index] = '\0';

      // printf("Found password: %s\n", s);

      time (&t2);
      double dif;
      dif = difftime (t2, t1);
      printf("%1.2f\n", dif);

      MPI_Abort(MPI_COMM_WORLD, MPI_SUCCESS);
    }
  }

}

int main(int argc, char **argv) 
{
  int numtasks, taskid;

  // Inicializa o MPI
  MPI_Init( &argc, &argv);
  MPI_Comm_size(MPI_COMM_WORLD, &numtasks);
  MPI_Status status;
  MPI_Comm_rank(MPI_COMM_WORLD, &taskid);

  char password[MAXIMUM_PASSWORD];
  strcpy(password, argv[1]);

  // Calcula os intervalos que cada processo vai trabalhar
  int base = END_CHAR - START_CHAR + 2;
  int size = strlen(password);
  long long int max = my_pow(base, size);
  long long int partialMax = max / numtasks;
  long long int taskMin = taskid * partialMax;
  long long int taskMax = (taskid + 1) * partialMax;
  int rest = max % numtasks;

  if (taskid == MASTER) {
    printf("P%dT%d;", numtasks, omp_get_num_threads());
  } 
  
  time (&t1);
  if (rest && taskid == numtasks - 1) {
    // Se houver resto da divisão, acrescenta no intervalo do último processo
    bruteForce(password, base, size, taskMin, taskMax + rest);
  } else {
    bruteForce(password, base, size, taskMin, taskMax);
  }

  MPI_Finalize();
  return 0;
}