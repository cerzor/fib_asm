#include <stdio.h>
#include <stdlib.h>
int main() {
  int fib_count;

  printf("Enter number of Fibonacci numbers to calculate: ");
  scanf("%d", &fib_count);
  printf("You entered: %d\n", fib_count);
  
  //make array to store results 
  uint64_t *results = (uint64_t *)malloc((fib_count + 1) * sizeof(uint64_t));
  
  results[0] = 0;
  results[1] = 1;
    
  for (int i = 2; i < fib_count + 1; i++){
    results[i] = results[i - 1] + results[i - 2];
  }
  
  printf("The number is: ");
  printf("%llu\n", results[fib_count - 1]);
  free(results);
  return 0;

}
