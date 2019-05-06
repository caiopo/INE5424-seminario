ISA=cortex-a9
CPU=realview-pbx-a9
COMPILER_PREFIX=/usr/local/arm/gcc-7.2.0/bin/arm

CC=$(COMPILER_PREFIX)-gcc
CXXFLAGS=-c -mcpu=${ISA} -g -fno-exceptions -fno-threadsafe-statics -nostdlib -lgcc

AS=$(COMPILER_PREFIX)-as

QEMU_FLAGS=-M ${CPU} -m 128M -nographic -no-reboot -serial stdio -monitor telnet:0.0.0.0:1234,server,nowait

export QEMU_AUDIO_DRV=none

.PHONY: all run clean objdump

all: compile link

compile:
	$(CC) $(CXXFLAGS) src/main.cpp -o src/main.o

	$(AS) src/startup.s -o src/startup.o

link:
	${COMPILER_PREFIX}-ld -T main.ld src/*.o -o main.elf
	${COMPILER_PREFIX}-objcopy -O binary main.elf main.bin

run:
	qemu-system-arm ${QEMU_FLAGS} -kernel main.bin

clean:
	rm src/*.o *.bin *.elf

objdump:
	${COMPILER_PREFIX}-objdump -S main.o
