.section .text

.global get_cpu_id
; unsigned int get_cpu_id()
; Returns the CPU ID (0 to 3) of the CPU executed on
get_cpu_id:
  MRC     p15, 0, r0, c0, c0, 5   ; Read CPU ID register
  AND     r0, r0, #0x03           ; Mask off, leaving the CPU ID field
  BX      lr


.global get_num_cpus
; unsigned int get_num_cpus(void)
; Returns the number of CPUs in the A9 Cluster
get_num_cpus

  ; Get base address of private perpherial space
  MRC     p15, 4, r0, c15, c0, 0  ; Read periph base address

  LDR     r0, [r0, #0x004]        ; Read SCU Configuration register
  AND     r0, r0, #0x3            ; Bits 1:0 gives the number of cores

  BX      lr


.global send_sgi
; void send_sgi(unsigned int ID, unsigned int target_list, unsigned int filter_list);
; Send a software generate interrupt
send_sgi PROC

  AND     r3, r0, #0x0F           ; Mask off unused bits of ID, and move to r3
  AND     r1, r1, #0x0F           ; Mask off unused bits of target_filter
  AND     r2, r2, #0x0F           ; Mask off unused bits of filter_list

  ORR     r3, r3, r1, LSL #16     ; Combine ID and target_filter
  ORR     r3, r3, r2, LSL #24     ; and now the filter list

  ; Get the address of the GIC
  MRC     p15, 4, r0, c15, c0, 0  ; Read periph base address
  ADD     r0, r0, #0x1F00         ; Add offset of the sgi_trigger reg

  STR     r3, [r0]                ; Write to the Software Generated Interrupt Register  (ICDSGIR)

  BX      lr
  ENDP
