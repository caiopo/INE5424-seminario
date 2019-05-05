#!/bin/bash

PATH=$PATH:/usr/local/ARM_Compiler_5/bin/

armcc  -g -c --cpu Cortex-A9.no_neon.no_vfp -O1 -I ./headers/ -o ./obj/main.o         ./src/main.c
armcc  -g -c --cpu Cortex-A9.no_neon.no_vfp -O1 -I ./headers/ -o ./obj/primes.o       ./src/primes.c
armcc  -g -c --cpu Cortex-A9.no_neon.no_vfp -O0 -I ./headers/ -o ./obj/retarget.o     ./src/retarget.c

armasm -g    --cpu Cortex-A9.no_neon.no_vfp                   -o ./obj/startup.o      ./src/startup.s
armasm -g    --cpu Cortex-A9.no_neon.no_vfp                   -o ./obj/A9MP_GIC.o     ./src/MP_GIC.s
armasm -g    --cpu Cortex-A9.no_neon.no_vfp                   -o ./obj/A9MP_SCU.o     ./src/MP_SCU.s
armasm -g    --cpu Cortex-A9.no_neon.no_vfp                   -o ./obj/A9MP_Mutexes.o ./src/MP_Mutexes.s
armasm -g    --cpu Cortex-A9.no_neon.no_vfp                   -o ./obj/v7.o           ./src/v7.s

armlink --scatter scatter_mmu.txt --entry Vectors -o image_A9.axf ./obj/startup.o ./obj/main.o ./obj/retarget.o ./obj/primes.o ./obj/A9MP_SCU.o ./obj/A9MP_GIC.o ./obj/A9MP_Mutexes.o ./obj/v7.o


