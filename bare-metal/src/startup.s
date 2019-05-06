.section .vector_table
.global _Reset
_Reset:
b Reset_Handler
b . // 0x4 Undefined Instruction
b . // 0x8 Software Interrupt
b . // 0xC Prefetch Abort
b . // 0x10 Data Abort
b . // 0x14 Reserved
b . // 0x18 IRQ
b . // 0x1C FIQ

.section .entry
Reset_Handler:
// init stack
ldr sp, =_stack_end

// clear bss
mov r0, #0
ldr r1, =_bss_start
ldr r2, =_bss_end

bss_loop:
cmp r1, r2
strlt r0, [r1], #4
blt bss_loop

// init static objects
ldr r0, =_init_array_start
ldr r1, =_init_array_end

globals_init_loop:
cmp     r0, r1
it      lt
ldrlt   r2, [r0], #4
blxlt   r2
blt     globals_init_loop

bl main
b .
