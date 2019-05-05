// ------------------------------------------------------------
// Main
//
// Copyright ARM Ltd 2009. All rights reserved.
// ------------------------------------------------------------

// C standard Libary
#include <stdio.h>

// Include project headers
#include "MP_SCU.h"
#include "MP_GIC.h"
#include "MP_Mutexes.h"
#include "primes.h"

// ------------------------------------------------------------

int main(void)
{
  unsigned int id;

  id = get_cpu_id();
  if (id == 0)
  {
    // init_uart();
    init_primes();
    send_sgi(0x0, 0x0F, 0x01); // Wake the secondary CPUs by sending SGI (ID 0)
  }

  printf("CPU %d: Starting calculation\n", id);

  calculate_primes(id);

  printf("CPU %d: Finished\n", id);

  return 0;
}

// ------------------------------------------------------------
// End of main.c
// ------------------------------------------------------------
