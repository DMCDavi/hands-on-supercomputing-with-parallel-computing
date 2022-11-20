#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

//97 to 122 use only lowercase letters
//65 to 90 use only capital letters
//48 to 57 use only numbers

#define START_CHAR 97
#define END_CHAR 122
#define MAXIMUM_PASSWORD 20

long long my_pow(long long x, int y)
{
  long long res = 1;
  if (y==0)
    return res;
  else
    return x * my_pow(x, y-1);
}

void bruteForce(char *pass) 
{
  int pass_b26[MAXIMUM_PASSWORD];
    
  long long int j;
  long long int pass_decimal = 0;
  int base = END_CHAR - START_CHAR + 2;

  int size = strlen(pass);

  // printf("Try to broke the password: %s\n", pass);

  for(int i = 0; i < size; i++)
    pass_b26[i] = (int) pass[i] - START_CHAR + 1; 

  for(int i = size - 1; i > -1; i--)
    pass_decimal += (long long int) pass_b26[i] * my_pow(base, i);

  long long int max = my_pow(base, size);
  char s[MAXIMUM_PASSWORD];

  for(j = 0; j < max; j++){
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
      break;
    }
  }

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

  printf("%1.2f\n", dif);

  return 0;
}