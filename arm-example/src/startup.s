; ------------------------------------------------------------
; Cortex-A9 MPCore SMP Prime Number Generator Example
;
; Copyright ARM Ltd 2009. All rights reserved.
; ------------------------------------------------------------

    PRESERVE8

  AREA  StartUp,CODE,READONLY

; ------------------------------------------------------------
; Define some values
; ------------------------------------------------------------

; - Standard definitions of mode bits and interrupt (I&F) flags in PSRs
Mode_USR          EQU   0x10
Mode_FIQ          EQU   0x11
Mode_IRQ          EQU   0x12
Mode_SVC          EQU   0x13
Mode_ABT          EQU   0x17
Mode_UNDEF        EQU   0x1B
Mode_SYS          EQU   0x1F
I_Bit             EQU   0x80 ; when I bit is set, IRQ is disabled
F_Bit             EQU   0x40 ; when F bit is set, FIQ is disabled



; ------------------------------------------------------------
; Porting defines
; ------------------------------------------------------------

PABASE_VA0        EQU   0x0         ; PA for virtual address 0x0 (Must be 1MB aligned)
PABASE_VA1        EQU   0x00100000  ; PA base for virtual address 0x0010,0000 (Must be 1MB aligned)
PABASE_UART       EQU   0x00000000  ; PA base of UART - only needed when retargeting

TTB_COHERENT      EQU   0x00014c06  ; Template descriptor for coherent memory
TTB_NONCOHERENT   EQU   0x00000c1e  ; Template descriptor for non-coherent memory
TTB_DEVICE        EQU   0x00000c06  ; Template descriptor for device memory

; ------------------------------------------------------------

  ENTRY

  EXPORT Vectors

Vectors
  B      Reset_Handler
  B      Undefined_Handler
  B      SWI_Handler
  B      Prefetch_Handler
  B      Abort_Handler
  NOP    ;Reserved vector
  B      IRQ_Handler
  B      FIQ_Handler

; ------------------------------------------------------------
; Handlers for unused exceptions
; ------------------------------------------------------------

Undefined_Handler
  B       Undefined_Handler
SWI_Handler
  B       SWI_Handler
Prefetch_Handler
  B       Prefetch_Handler
Abort_Handler
  B       Abort_Handler
FIQ_Handler
  B       FIQ_Handler
  
; ------------------------------------------------------------
; Imports
; ------------------------------------------------------------

  IMPORT read_irq_ack
  IMPORT write_end_of_irq
  IMPORT enable_GIC
  IMPORT enable_gic_processor_interface
  IMPORT set_priority_mask
  IMPORT enable_irq_id
  IMPORT set_irq_priority
  IMPORT enable_scu
  IMPORT join_smp
  IMPORT secure_SCU_invalidate
  IMPORT enable_maintenance_broadcast
  IMPORT __main

; ------------------------------------------------------------
; Interrupt Handler
; ------------------------------------------------------------

  EXPORT IRQ_Handler
IRQ_Handler   PROC
  SUB     lr, lr, #4          ; Pre-adjust lr
  SRSFD   sp!, #Mode_IRQ      ; Save lr and SPRS to IRQ mode stack
  PUSH    {r0-r4, r12}        ; Sace APCS corruptable registers to IRQ mode stack (and maintain 8 byte alignment)

  ; Acknowledge the interrupt
  BL      read_irq_ack
  MOV     r4, r0
  
  ;
  ; This example only uses (and enables) one.  At this point
  ; you would normally check the ID, and clear the source.
  ;

  ; Write end of interrupt reg
  MOV     r0, r4
  BL      write_end_of_irq

  POP     {r0-r4, r12}        ; Restore stacked APCS registers
  MOV     r2, #0x01           ; Set r2 so CPU leaves holding pen
  RFEFD   sp!                 ; Return from exception

  ENDP

; ------------------------------------------------------------
; Reset Handler - Generic initialization, run by all CPUs
; ------------------------------------------------------------

  IMPORT ||Image$$IRQ_STACK$$ZI$$Limit||
  IMPORT ||Image$$ARM_LIB_STACKHEAP$$ZI$$Limit||
  IMPORT ||Image$$PAGETABLES$$ZI$$Base||
  IMPORT enable_branch_prediction
  IMPORT invalidate_caches

  EXPORT Reset_Handler   ; Exported for callgraph purposes!
Reset_Handler PROC

  ;
  ; Setup stacks
  ;---------------
  MSR     CPSR_c, #Mode_IRQ:OR:I_Bit:OR:F_Bit
  LDR     sp, =||Image$$IRQ_STACK$$ZI$$Limit||

  MSR     CPSR_c, #Mode_SYS:OR:I_Bit:OR:F_Bit   ; No interrupts
  LDR     sp, =||Image$$ARM_LIB_STACKHEAP$$ZI$$Limit||


  ;
  ; MMU Init
  ; ---------

  ;
  ; Invalidate caches
  ; ------------------
  BL      invalidate_caches

  ;
  ; Clear Branch Prediction Array
  ; ------------------------------
  MOV     r0, #0x0
  MCR     p15, 0, r0, c7, c5, 6     ; BPIALL - Invalidate entire branch predictor array

  ;
  ; Invalidate TLBs
  ;------------------
  MOV     r0, #0x0
  MCR     p15, 0, r0, c8, c7, 0     ; TLBIALL - Invalidate entire Unifed TLB

  ;
  ; Set up Domain Access Control Reg
  ; ----------------------------------
  ; b00 - No Access (abort)
  ; b01 - Client (respect table entry)
  ; b10 - RESERVED
  ; b11 - Manager (ignore access permissions)
  ; Setting D0 to client, all others to No Access
  MOV     r0, #0x01
  MCR     p15, 0, r0, c3, c0, 0


  ; Page tables
  ; -------------------------
  ; Each CPU will have its own L1 page table.  The
  ; code reads the base address from the scatter file
  ; the uses the CPUID to calculate an offset for each
  ; CPU.
  ;
  ; The page tables are generated at boot time.  First
  ; the table is zeroed.  Then the individual valid 
  ; entries are written in
  ;

  ; Calculate offset for this CPU
  LDR     r0, =||Image$$PAGETABLES$$ZI$$Base||
  MRC     p15, 0, r1, c0, c0, 5     ; Read Multiprocessor Affinity Register
  ANDS    r1, r1, #0x03             ; Mask off, leaving the CPU ID field
  MOV     r1, r1, LSL #14           ; Convert core ID into a 16K offset (this is the size of the table)
  ADD     r0, r1, r0                ; Add offset to current table location to get dst

  ; Fill table with zeros
  MOV     r2, #1024                 ; Set r3 to loop count (4 entries per iteration, 1024 iterations)
  MOV     r1, r0                    ; Make a copy of the base dst
  MOV     r3, #0
  MOV     r4, #0
  MOV     r5, #0
  MOV     r6, #0
ttb_zero_loop
  STMIA   r1!, {r3-r6}              ; Store out four entries
  SUBS    r2, r2, #1                ; Decrement counter
  BNE     ttb_zero_loop

  ;
  ; STANDARD ENTRIES
  ;

  ; Entry for VA 0x0
  ; This region must be coherent
  LDR     r1, =PABASE_VA0           ; Physical address
  LDR     r2, =TTB_COHERENT         ; Descriptor template
  ORR     r1, r1, r2                ; Combine address and template
  STR     r1, [r0]

  ; Entry for VA 0x0010,0000
  ; Each CPU stores private data in this address range
  ; Using the MMU to map to different PA on each CPU.
  ; 
  ; CPU 0 - PA Base
  ; CPI 1 - PA Base + 1MB
  ; CPU 2 - PA Base + 2MB
  ; CPU 3 - PA Base + 3MB

  MRC     p15, 0, r1, c0, c0, 5     ; Re-read Multiprocessor Affinity Register
  AND     r1, r1, #0x03             ; Mask off, leaving the CPU ID field
  MOV     r1, r1, LSL #20           ; Convert core ID into a MB offset
  
  LDR     r3, =PABASE_VA1           ; Base PA
  ADD     r1, r1, r3                ; Add CPU offset to PA
  LDR     r2, =TTB_NONCOHERENT      ; Descriptor template
  ORR     r1, r1, r2                ; Combine address and template
  STR     r1, [r0, #4]

  ; Entry for private address space
  ; Needs to be marked as Device memory
  MRC     p15, 4, r1, c15, c0, 0    ; Get base address of private address space
  LSR     r1, r1, #20               ; Clear bottom 20 bits, to find which 1MB block its in
  LSL     r2, r1, #2                ; Make a copy, and multiply by four.  This gives offset into the page tables
  LSL     r1, r1, #20               ; Put back in address format

  LDR     r3, =TTB_DEVICE           ; Descriptor template
  ORR     r1, r1, r3                ; Combine address and template
  STR     r1, [r0, r2]
  
  ;
  ; OPTIONAL ENTRIES
  ; You will need additional translations if:
  ; - No RAM at zero, so cannot use flat mapping
  ; - You wish to retarget
  ;

  ; If not flat mapping, you need a page table entry covering
  ; the physical address of the boot code.
  ;LDR     r1, =PABASE_VA0           ; Physical address
  ;LSR     r2, r1, #18               ; Make a copy of PA, and convert in table offset
  ;LDR     r3, =TTB_COHERENT         ; Descriptor template
  ;ORR     r1, r1, r3                ; Combine address and template
  ;STR     r1, [r0, r2]

  ; If you wish to output to stdio to a UART you will need
  ; an additional entry
  ;LDR     r1, =PABASE_UART          ; Physical address of UART
  ;LSR     r1, r1, #20               ; Mask off bottom 20 bits to find which 1MB it is within
  ;LSL     r2, r1, #2                ; Make a copy and multiply by 4 to get table offset
  ;LSL     r1, r1, #20               ; Put back into address format
  ;LDR     r3, =TTB_DEVICE           ; Descriptor template
  ;ORR     r1, r1, r3                ; Combine address and template
  ;STR     r1, [r0, r2]

  ;
  ; Barrier
  ; --------
  DSB

  ;
  ; Set location of level 1 page table
  ;------------------------------------
  ; 31:14 - Base addr 0x8400,0000
  ; 13:5  - 0x0
  ; 4:3   - RGN 0x0 (Outer Noncachable)
  ; 2     - P   0x0
  ; 1     - S   0x0 (Non-shared)
  ; 0     - C   0x0 (Inner Noncachable)
  MCR     p15, 0, r0, c2, c0 ,0


  ; Enable MMU
  ;-------------
  ; 0     - M, set to enable MMU
  ; Leaving the caches disabled until after scatter loading.
  MRC     p15, 0, r0, c1, c0, 0     ; Read current control reg
  ORR     r0, r0, #0x01             ; Set M bit
  MCR     p15, 0, r0, c1, c0, 0     ; Write reg back

  ;
  ; MMU now enable - Virtual address system now active
  ;

  ;
  ; Branch Prediction Init
  ; -----------------------
  BL      enable_branch_prediction

  ;
  ; SMP initialization 
  ; -------------------
  MRC     p15, 0, r0, c0, c0, 5     ; Read CPU ID register
  ANDS    r0, r0, #0x03             ; Mask off, leaving the CPU ID field
  BLEQ    primary_cpu_init
  BLNE    secondary_cpus_init

  ENDP

; ------------------------------------------------------------
; Initialization for PRIMARY CPU
; ------------------------------------------------------------

   EXPORT primary_cpu_init
primary_cpu_init PROC

  ; Enable the SCU
  ; ---------------
  BL      enable_scu
  
  ;
  ; Join SMP
  ; ---------
  MOV     r0, #0x0                  ; Move CPU ID into r0
  MOV     r1, #0xF                  ; Move 0xF (represents all four ways) into r1
  BL      secure_SCU_invalidate
  BL      join_smp
  BL      enable_maintenance_broadcast
  
  ;
  ; GIC Init
  ; ---------
  BL      enable_GIC
  BL      enable_gic_processor_interface

  ;
  ; Branch to C lib code
  ; ----------------------
  B       __main


  ENDP

; ------------------------------------------------------------
; Initialization for SECONDARY CPUs
; ------------------------------------------------------------

  EXPORT secondary_cpus_init
secondary_cpus_init PROC

  ;
  ; GIC Init
  ; ---------
  BL      enable_gic_processor_interface

  MOV     r0, #0x1F                 ; Priority
  BL      set_priority_mask

  MOV     r0, #0x0                  ; ID
  BL      enable_irq_id

  MOV     r0, #0x0                  ; ID
  MOV     r1, #0x0                  ; Priority
  BL      set_irq_priority

  ;
  ; Join SMP
  ; ---------
  MRC     p15, 0, r0, c0, c0, 5     ; Read CPU ID register
  ANDS    r0, r0, #0x03             ; Mask off, leaving the CPU ID field
  MOV     r1, #0xF                  ; Move 0xF (represents all four ways) into r1
  BL      secure_SCU_invalidate
  
  BL      join_smp
  BL      enable_maintenance_broadcast

  ;
  ; Holding Pen
  ; ------------
  MOV     r2, #0x00                 ; Clear r2
  CPSIE   i                         ; Enable interrupts
holding_pen
  CMP     r2, #0x0                  ; r2 will be set to 0x1 by IRQ handler on receiving SGI
  WFIEQ
  BEQ     holding_pen
  CPSID   i                         ; IRQs not used in reset of example, so mask out interrupts
skip

  ;
  ; Branch to C lib code
  ; ----------------------
  B       __main


  ENDP
  
; ------------------------------------------------------------
; End of code
; ------------------------------------------------------------

  END

; ------------------------------------------------------------
; End of startup.s
; ------------------------------------------------------------
