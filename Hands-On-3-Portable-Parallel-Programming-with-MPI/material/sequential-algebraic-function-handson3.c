#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

#define MASTER 0

int main(int argc, char ** argv) {

  int numtasks, taskid, dest, source, i, tag1 = 1000, tag2 = 2000, coefficient_position;
  double coefficient[4], x, suma, sumatotal = 0;
  char c;

  /*-------------- INITIALIZE MPI -----------------*/
  MPI_Init( &argc, &argv);
  MPI_Comm_size(MPI_COMM_WORLD, &numtasks);
  MPI_Status status;
  MPI_Comm_rank(MPI_COMM_WORLD, &taskid);
  /*-----------------------------------------------*/

  if (taskid == MASTER) {
    printf("\nf(x) = a*x^3 + b*x^2 + c*x + d\n");

    /*-------------- CREATE FUNCTION -----------------*/
    /* ESSA PARTE FOI COMENTADA PORQUE NO COLAB O SCANF DENTRO DE UM LOOP COM MPI NÃO FUNCIONA
    for (c = 'a'; c < 'e'; c++) {
      printf("\nEnter the value of the 'constants' %c:\n", c);
      scanf("%lf", &coefficient[c - 'a']);
    }

    printf("\nEnter the value of 'x':\n");
    scanf("%lf", &x);
    */

    coefficient[0] = 1.0;
    coefficient[1] = 2.0;
    coefficient[2] = 3.0;
    coefficient[3] = 4.0;
    x = 5.0;

    printf("\nf(%lf) = %lf*x^3 + %lf*x^2 + %lf*x + %lf\n", x, coefficient[0], coefficient[1], coefficient[2], coefficient[3]);
    /*------------------------------------------------*/


    /*-------------- MASTER SEND TO WORKERS -----------------*/
    for (i = 1; i < numtasks; i++){
      dest = i;
      coefficient_position = i - 1;

      MPI_Send( &coefficient[coefficient_position], 1, MPI_DOUBLE, dest, tag1, MPI_COMM_WORLD);
      MPI_Send( &x, 1, MPI_DOUBLE, dest, tag2, MPI_COMM_WORLD);
      if (i == 3) {
        MPI_Send( &coefficient[3], 1, MPI_DOUBLE, dest, tag1, MPI_COMM_WORLD);
      }
    }

    /*-------------- MASTER RECEIVE FROM WORKERS -----------------*/
    for (i = 1; i < numtasks; i++) {
      source = i;
      MPI_Recv( &suma, 1, MPI_DOUBLE, source, 3, MPI_COMM_WORLD, &status);
      sumatotal += suma;
      printf("Sum from worker-%d = %lf\n", source, suma);
    }

    printf("Result = %lf\n", sumatotal);
  }

  /*-------------- WORKERS -----------------*/
  if (taskid > MASTER) {
    dest = MASTER;
    source = MASTER;
    coefficient_position = taskid - 1;

    /*-------------- WORKER RECEIVE FROM MASTER -----------------*/
    MPI_Recv( &coefficient[coefficient_position], 1, MPI_DOUBLE, source, tag1, MPI_COMM_WORLD, &status);
    MPI_Recv( &x, 1, MPI_DOUBLE, source, tag2, MPI_COMM_WORLD, &status);
    /*-----------------------------------------------------------*/

    suma = coefficient[coefficient_position] * x;

    /*-------------- WORKERS OPERATIONS -----------------*/
    if (taskid == 1) {
      suma *= x * x;
    } else if (taskid == 2) {
      suma *= x;
    } else if (taskid == 3) {
      MPI_Recv( &coefficient[3], 1, MPI_DOUBLE, source, tag1, MPI_COMM_WORLD, &status);
      suma += coefficient[3];
    }

    /*-------------- WORKER SEND TO MASTER -----------------*/
    MPI_Send( &suma, 1, MPI_DOUBLE, dest, 3, MPI_COMM_WORLD);
  }

  MPI_Finalize();
  return 0;
}