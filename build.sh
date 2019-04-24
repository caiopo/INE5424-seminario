#! /bin/bash

set -e

ISA=cortex-a9
CPU=realview-pbx-a9
ARM=/usr/local/arm/gcc-7.2.0/bin/arm

${ARM}-as -mcpu=${ISA} -g startup.s -o startup.o
${ARM}-gcc -c -mcpu=${ISA} -g test.c -o test.o
${ARM}-ld -T test.ld test.o startup.o -o test.elf
${ARM}-objcopy -O binary test.elf test.bin

qemu-system-arm -M ${CPU} -m 128M -nographic -no-reboot -kernel test.bin
