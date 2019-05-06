.section .vector_table
.global _reset
_reset:
b _start // 0x0 Reset
b .      // 0x4 Undefined Instruction
b .      // 0x8 Software Interrupt
b .      // 0xC Prefetch Abort
b .      // 0x10 Data Abort
b .      // 0x14 Reserved
b .      // 0x18 IRQ
b .      // 0x1C FIQ

.section .entry
_start:
// init stack
ldr sp, =_stack_end

// clear bss
mov r0, #0
ldr r1, =_bss_start
ldr r2, =_bss_end

bss_loop:
cmp   r1, r2
strlt r0, [r1], #4
blt   bss_loop

// init static objects
ldr r0, =_init_array_start
ldr r1, =_init_array_end

globals_init_loop:
cmp   r0, r1
ldrlt r2, [r0], #4
blxlt r2
blt   globals_init_loop

// jump to main
bl main

// destroy static objects in reverse order
ldr r0, =_fini_array_start
ldr r1, =_fini_array_end

globals_fini_loop:
cmp   r0, r1
ldrlt r2, [r0], #4
blxlt r2
blt   globals_fini_loop

// freeze forever
b .
