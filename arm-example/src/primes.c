// ------------------------------------------------------------
// Prime Number Generator Code
//
// Copyright ARM Ltd 2009. All rights reserved.
// ------------------------------------------------------------

#include <stdio.h>
#include "MP_Mutexes.h"

#define TARGET_COUNT (10000)

// ------------------------------------------------------------
unsigned int target;
unsigned int prime_numbers[TARGET_COUNT];
unsigned int next_number;

volatile unsigned int prime_count;

__align(32) mutex_t primeLock;         // Aligning the mutexes to the cache line size
__align(32) mutex_t nextNumLock;      

// ------------------------------------------------------------

static unsigned int get_next_number()
{
  unsigned int number;

  lock_mutex(&nextNumLock);
  number = next_number;
  next_number = next_number + 2;
  unlock_mutex(&nextNumLock);

  return number;
}

// ------------------------------------------------------------

static void add_prime(unsigned int number, unsigned int id)
{
  lock_mutex(&primeLock);
  
  // It is possible a CPU could skid past the target number of primes
  // so adding a check to avoid potential writes past the end of the array
  if (prime_count < TARGET_COUNT)
  {
    prime_numbers[ (prime_count - 1) ] = number;
    prime_count++;
  }
  
  printf("CPU %d: %d\n", id, number);

  unlock_mutex(&primeLock);

  return;
}

// ------------------------------------------------------------

void init_primes(void)
{
  // Initialize mutexes
  init_mutex(&primeLock);
  init_mutex(&nextNumLock);

  // Set initial
  target = TARGET_COUNT;
  prime_count = 0;

  // Give it the first few primes to get going...
  prime_numbers[prime_count] = 2;
  prime_count++;
  prime_numbers[prime_count] = 3;
  prime_count++;
  prime_numbers[prime_count] = 5;
  prime_count++;
  prime_numbers[prime_count] = 7;
  prime_count++;
  prime_numbers[prime_count] = 11;
  prime_count++;
  prime_numbers[prime_count] = 13;
  prime_count++;
  prime_numbers[prime_count] = 17;
  prime_count++;
  prime_numbers[prime_count] = 19;
  prime_count++;
  prime_numbers[prime_count] = 23;
  prime_count++;
  prime_numbers[prime_count] = 29;
  prime_count++;
  prime_numbers[prime_count] = 31;
  prime_count++;
  prime_numbers[prime_count] = 37;
  prime_count++;

  next_number = 39;

  return;
}

// ------------------------------------------------------------

void calculate_primes(unsigned int id)
{
  int number;
  int square;
  int remainder;
  int root = 1;
  int prime;
  int i;

  // Get initial number
  number = get_next_number();

  while(prime_count < target)
  {
    square = root * root;
    
    while(number > square)
    {
      root++;
      square = root * root;
    }
    
    for(i=1; i < prime_count; i++)
    {
      prime = prime_numbers[i];
      
      if (prime > root)
      {
        add_prime(number, id);
        break;
      }

      remainder = number % prime;
  
      if (remainder == 0) 
      {
        // not a prime, so ditch number
        break;
      }
    }

    // Get the next number
    number = get_next_number();
  }
  return;
}

// ------------------------------------------------------------
// End of primes.c
// ------------------------------------------------------------
