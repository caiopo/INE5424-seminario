// ------------------------------------------------------------
// Prime Number Generator Code
// Header
//
// M.Weidmann - ARM Support Group
// ------------------------------------------------------------

#ifndef _PRIMES_
#define _PRIMES_

// Initializes shared data used during calculation of primes
// Must be called by CPU 0 only, before any CPU calls calculate_primes()
void init_primes(void);

// Starts calculation of primes on that CPU
// Must be called by each particapting CPU
void calculate_primes(unsigned int id);

#endif

// ------------------------------------------------------------
// End of primes.h
// ------------------------------------------------------------
