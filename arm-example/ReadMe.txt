Cortex-A MPCore SMP Prime Number Generator Example
====================================================

This example demonstrates a "simple" bare metal SMP system, using the hardware resources of the Cortex-A MPCore (MP).  The CPUs in the MP cluster working co-operatively on a shared task - generating prime numbers.

The example includes code for configuring the MP's Interrupt Controller, SCU, MMU, caches, branch predictor, and private timer.

The intention of this example is to be readable and easy to follow, not provide optimal performance.  The example is not modelled on an operating system, and does not use a threading library.  A more advanced example, based on pthreads, is available separately:

    http://www.arm.com/products/CPUs/mpcore-samplecode.html


Version
========
2.0


Support
========
The example is provided "as is" and without any support entitlement.  If you have questions you can try public resources, such as the ARM forums (http://forums.arm.com).


Prerequisites
==============
The example requires RVDS 4.1 Professional SP1 (or later).

It can be run on the Cortex-A9 MPCore and Cortex-M5 MPCore RTSMs provided with RVDS 4.1 Professional, and on the Versatile PBX-A9.

It can also be run on the Versatile Emulation Baseboard + Cortex-A9 MPCore example systems provided with the Fast Model Portfolio 5.0 SP1 (and later).

The instructions assume a familiarity with the RVCT and RVD.


Running a Cortex-A9 MPCore Dual Core RTSM
==========================================
* Run build_A9.bat/build_A9.sh to build the example
* Add a connection for the dual core Cortex-A9 MPCore RTSM, and connect to both CPUs
* Open a second RVD window (View -> New Code Window), and attach a CPU with each window
* Load the image (image_A9.axf) to CPU0, and the symbols to CPU1
* On either CPU, run the simulation
* You will see the output of the example written to the StdIO tab of the Output pane


Running a Cortex-A5 MPCore Dual Core RTSM
==========================================
* Run build_A5.bat/build_A5.sh to build the example
* Add a connection for the dual core Cortex-A9 MPCore RTSM, and connect to both CPUs
* Open a second RVD window (View -> New Code Window), and attach a CPU with each window
* Load the image (image_A5.axf) to CPU0, and the symbols to CPU1
* On either CPU, run the simulation
* You will see the output of the example written to the StdIO tab of the Output pane


Running a Versatile PBX-A9
===========================
* Run build_A9.bat/build_A9.sh to build the example
* Add a RVI configuration, and configure for your Versatile PBX-A9 board
* Connect to all the CPUs
* Open an additional RVD windows (View -> New Code Window) for each CPU, and attach a CPU with each window
* Load the image (image_A9.axf) to CPU0, and the symbols to the other CPUs
* Start each of the CPUs
* You will see the output of the example written to the StdIO tab of the Output pane


Running with the Fast Models & Model Debugger
==============================================
* Run build_A9.bat/build_A9.sh to build the example
* Open the Build_EBCortexAMPx2 example ($PVLIB_HOME\examples\RTSMEmulationBaseboard\Build_EBCortexAMPx2\RTSM_EBCortexAMPx2.sgproj) in the System Canvas, and click Build
* Once built, click Debug to launch Model Debugger
* Accept the default parameter configurations and select to connect to both CPU0 and CPU1
* When prompted, load the image (image_A9.axf) to CPU0 and ensure that the "Enable SMP Application Loading" option is selected.
* Run the simulation
* You will see the output of the example written to the StdIO tab of the Output window

Expected Output
================
CPU 0: Starting calculation      CPU 1: Starting calculation
CPU 0: 41                        CPU 1: 53
CPU 0: 43                        CPU 1: 61
CPU 0: 47                        CPU 1: 71
...                              ...
CPU 0: 100279                    CPU 1: 100291
CPU 0: Finished                  CPU 1: Finished

Note 1: The output for each CPU will go to the GUI window (RVD or Model Debugger) attached to that CPU.
NOTE 2: CPU0 will usually have calculated the first few numbers before CPU1 starts.
NOTE 3: The prime number generating algorithm has undergone only minor testing.


File List
==========

 <root>
  |-> /headers
  |     |-> MP_GIC.h              C header file for GIC handling functions
  |     |-> MP_Mutexes.h          C header file for Mutex functions
  |     |-> MP_PrivateTimer.h     C header file for Private Timer functions (unused)
  |     |-> MP_PrivateWatchdog.h  C header file for Private Watchdog functions (unused)
  |     |-> MP_GlobalTimer.h      C header file for Global Timer functions (unused)
  |     |-> MP_SCU.h              C header file for SCU handling functions
  |     |-> v7.h                  C header file for misc v7-A helper functions
  |     |-> primes.h
  |-> /obj                        This is where generated objected files will be placed
  |-> /src
  |     |-> MP_GIC.s              Implementation of GIC handling functions
  |     |-> MP_Mutexes.s          Implementation of Mutex functions
  |     |-> MP_PrivateTimer.s     Implementation of Private Timer functions (unused)
  |     |-> MP_PrivateWatchdog.s  Implementation of Private Watchdog functions (unused)
  |     |-> MP_GlobalTimer.s      Implementation of Global Timer functions (unused)
  |     |-> MP_SCU.s              Implementation of SCU handling functions
  |     |-> v7.h                  Implementation of misc v7-A helper functions
  |     |-> main.c                main()
  |     |-> primes.c              Prime number generating code
  |     |-> retarget.c            Wrapper for main() which enables the L1 caches
  |     |-> startup.s             Initialization code, including vector table
  |-> build_A5.bat                Build script for Cortex-A5 MPCore (DOS)
  |-> build_A5.sh                 Build script for Cortex-A5 MPCore (BASH)
  |-> build_A9.bat                Build script for Cortex-A9 MPCore (DOS)
  |-> build_A9.sh                 Build script for Cortex-A9 MPCore (BASH)
  |-> ReadMe.txt                  This file
  |-> scatter_mmu.txt             scatter file


Description
============
This example shows a bare metal SMP system.  Up to four CPUs boot and work co-operatively on generating prime numbers.  The prime number generator code is shared between the CPUs, and uses mutexes to control access to shared resources.

Memory Map
-----------

                Virtual Address Space    Physical Address Space
                                              (DEFAULT)
 0xFFFF,FFFF    ---------------------    ---------------------
                |                   |    |                   |
                |      ABORT        |    |      ABORT        |
 0x1F10,0000    |                   |    |                   |
 0x1F0F,FFFF    ---------------------    ---------------------
                | Internal Address  |    | Internal Address  |
 0x1F00,0000    | space of the MP   |    | space of the MP   |
 0x1EFF,FFFF    ---------------------    ---------------------
                |                   |    |                   |
                |      ABORT        |    |      ABORT        |
 0x0060,0000    |                   |    |                   |
 0x005F,FFFF    ---------------------    ---------------------
                |    Page tables    |    |    Page tables    |
 0x0050,0000    |                   |    |                   |
 0x004F,FFFF    ---------------------    ---------------------
                |                   |    |     CPU3 Local    |
                |                   |    |        Mem        |
                |                   |    ---------------------
                |      ABORT        |    |     CPU2 Local    |
                |                   |    |        Mem        |
                |                   |    ---------------------
                |                   |    |     CPU1 Local    |
 0x0020,0000    |                   |    |        Mem        |
 0x001F,FFFF    ---------------------    ---------------------
                |   CPU{n} Local    |    |     CPU0 Local    |
 0x0010,0000    |       Mem         |    |        Mem        |
 0x000F,FFFF    ---------------------    ---------------------
                |  Coherent Memory  |    |  Coherent Memory  |
 0x0000,0000    |      & Code       |    |      & Code       |
                ---------------------    ---------------------

Shared data and code is located in the bottom MB of memory.  This memory is configured as Coherent in the page tables.  The second MB of virtual address space is used to store CPU specific data (e.g. the stack and heap).  For each CPU this maps to a different MB of physical space.

Boot
-----
The boot sequence for the example is shown below:

  Reset Vector
       |
  Reset_Handler()
       |
       ----------------------
       |                    |
  primary_cpu_init()   secondary_cpus_init()
       |                    |
    __main()                |
       |                    |
     main()                 |
       |                    |
  init_primes()             |
       |                    |
   send_sgi()               |
       |                    |
  calculate_primes()     __main()
                            |
                          main()
                            |
                      calculate_primes()

The first stage of boot is the reset hander, which is common to all CPUs.  In this stage the stack pointers, MMU, caches and branch predictor are initialized.  Each CPU has its own L1 page table, which is generated at run time.  As described above each CPU stores private data (e.g. stacks) in the virtual address range 0x0010,0000-0x001F,FFFF.  When the page tables are generated the CPU's ID is used to calculate offset for the physical address.

For the second stage of boot CPU0 is treated as the primary CPU, with the other CPUs treated as secondary.

The secondary CPUs (CPUs 1-3) branch to secondary_cpus_init().  This function carries out only CPU specific (local) initialization.  For the example this involves enabling the Processor Interface of the Interrupt Controller, and enabling the receipt of Software Generated Interrupts (SGIs).  Once the initialization is complete the CPUs enter a holding pen.  They are released from the holding pen by a SGI from the primary CPU.

CPU0 is the primary CPU and branches to primary_cpu_init().  This function performs some local initialization, but also the cluster wide (global) configuration.  This includes  configuring the SCU, and the global enable for the Interrupt Controller.  On reaching main() the primary CPU also  initializes the global data used by the application.  Once this is done it releases the secondary CPUs from the holding pen by sending a SGI.

Application
------------
The application is a simple prime number generator, which is run co-operatively by all the CPUs.  The application's global data is stored in coherent memory, with mutexes used to control access.

The body of the application is in the function calculate_primes() and consists of a loop:

  Get next number to test
  
  Test number
  
  If number is prime, store to list of primes found
  
The application's global data consists of:

  prime_numbers[] - Array of the prime numbers found so far
  next_number     - The next number to be tested
  prime_count     - How many prime numbers have been found so far
  
The globals are updated using accessor functions.  These functions handle the locking and releasing of the relevent mutex:

  get_next_number() - Returns the next number to test
  add_prime()       - Adds a prime to prime_numbers[] and increments prime_count

The example uses a simple mutex implementation:

  init_mutex()      - Initializes the mutex, called once per mutex at start-up
  lock_mutex()      - Blocking call, returns once mutex lock aquired
  unlock_mutex()    - Release mutex, returns error if not called by current owner
  
The lock_mutex() function uses the WFE (Wait For Event) instruction to put the CPU into standby if the requested mutex is currently locked.  The unlock_mutex() executes the SEV (Send Event Instruction) instruction to wake any CPUs waiting on a mutex.


Porting
========
The example is intended to be simple to port to other platforms.  The main porting requirements are to set the physical location of RAM in the system.  This is done by modifying the following defines in startup.s:

PABASE_VA0        - Base physical address of 1MB of RAM, to be mapped to VA 0x0
PABASE_VA1        - Base physical address of 4MB of RAM, to be mapped to VA 0x0010,0000

Both PABASE_VA0 and PABASE_VA1 must be 1MB aligned.

If PABASE_VA0 is not 0x0, then you must also uncomment the optional section starting at line 250.  Additionally, you will have to manually load the image to the correct PA.


Feedback
=========
While support is not offered on this example, feedback is welcome.  Please e-mail support@arm.com
