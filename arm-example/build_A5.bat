armcc  -g -c --cpu Cortex-A5 -O1 -I ./headers/ -o ./obj/main.o         ./src/main.c
armcc  -g -c --cpu Cortex-A5 -O1 -I ./headers/ -o ./obj/primes.o       ./src/primes.c
armcc  -g -c --cpu Cortex-A5 -O0 -I ./headers/ -o ./obj/retarget.o     ./src/retarget.c

armasm -g    --cpu Cortex-A5                   -o ./obj/startup.o      ./src/startup.s
armasm -g    --cpu Cortex-A5                   -o ./obj/A5MP_GIC.o     ./src/MP_GIC.s
armasm -g    --cpu Cortex-A5                   -o ./obj/A5MP_Mutexes.o ./src/MP_Mutexes.s
armasm -g    --cpu Cortex-A5                   -o ./obj/A5MP_SCU.o     ./src/MP_SCU.s
armasm -g    --cpu Cortex-A5                   -o ./obj/v7.o           ./src/v7.s

armlink --scatter scatter_mmu.txt --entry Vectors -o image_A5.axf ./obj/startup.o ./obj/main.o ./obj/primes.o ./obj/retarget.o ./obj/A5MP_SCU.o ./obj/A5MP_GIC.o ./obj/A5MP_Mutexes.o ./obj/v7.o


