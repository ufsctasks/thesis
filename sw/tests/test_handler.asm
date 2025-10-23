# ##########################################################
# MIPS - Exceptions Simulation of CP0
# ##########################################################

.data
Count:      	.word 0
Compare:    	.word 10
Flag:       	.word 0
#invalid_instr: 	.word 0xFFFFFFFF0

msg_start:      .asciiz "\n--- EXCEPTIONS SIMULATOR CP0 (REAL EVENTS) ---\n"
msg_interrupt:  .asciiz "Timer: Count == Compare -> Interruption generated!\n"
msg_overflow:   .asciiz "Performing ADD overflow test...\n"
msg_divzero:    .asciiz "Performing DIV by zero test...\n"
msg_syscall:    .asciiz "Performing SYSCALL test...\n"
msg_ri:         .asciiz "Performing Reserved Instruction (RI) test...\n"
msg_handler:    .asciiz ">>> Entering handler (Exception detected)...\n"
msg_done:       .asciiz "Interruption/Exception handled.\n"
msg_end:        .asciiz "\n--- End of Simulation ---\n"

.text
.globl main

# ##########################################################
# MAIN
# ##########################################################
main:
    li $v0, 4
    la $a0, msg_start
    syscall

    # Enable global interrupts (Status)
    li   $t0, 0x0000FF11
    mtc0 $t0, $12

# ##########################################################
# TEST 1: Timer interrupt (Count == Compare)
# ##########################################################
    li   $t1, 10
    sw   $t1, Count
    lw   $t2, Compare
    beq  $t1, $t2, interrupt_case
    nop
    
    interrupt_case:
    li $v0, 4
    la $a0, msg_interrupt
    syscall

    li $t3, 0x00008000       # Cause.IP7 = 1
    mtc0 $t3, $13
    li $t4, 0x00000000       # ExcCode = 0
    mtc0 $t4, $13
    jal handler
    nop

# ##########################################################
# TEST 2: Arithmetic Overflow (real)
# ##########################################################
overflow_case:
    li $v0, 4
    la $a0, msg_overflow
    syscall

    # real overflow: 2^31 - 1 + 1 → overflow
    li  $t1, 0x7FFFFFFF       # biggest positive integer number (2147483647)
    #addi $t1, $t1, 1
    # this line end the execution. (real overflow).
    li $t4, 0x00003000       # ExcCode = 12 (overflow)
    mtc0 $t4, $13
    jal handler
    nop 


# ##########################################################
# TEST 3: Division by Zero (real)
# ##########################################################
divzero_case:
    li $v0, 4
    la $a0, msg_divzero
    syscall

    li $t2, 10               
    li $t3, 0                
    div $t2, $t3
    li $t4, 0x00003C00      # ExcCode = 15
    mtc0 $t4, $13            

# ##########################################################
# TEST 4: Syscall (real)
# ##########################################################
syscall_case:
    li $v0, 4
    la $a0, msg_syscall
    syscall
    li $t4, 0x00002000      # ExcCode = 8
    mtc0 $t4, $13
    syscall                  

# ##########################################################
# TEST 5: Reserved Instruction (RI)
# ##########################################################
# ri_case:
#    li $v0, 4
#    la $a0, msg_ri
#   syscall

#    la $t0, invalid_instr     
#    jr $t0       
#    li $t4, 0x00002800      # ExcCode = 10
#    mtc0 $t4, $13             
#    nop

# ##########################################################
# END CODE
# ##########################################################
end_sim:
    li $v0, 4
    la $a0, msg_end
    syscall

    li $v0, 10
    syscall


# ##########################################################
# HANDLER (simulated)
# ##########################################################
handler:
    li $v0, 4
    la $a0, msg_handler
    syscall

    # Save EPC (return address)
    la $t5, main
    mtc0 $t5, $14

    # Mark flag and print messages
    li $t7, 1
    sw $t7, Flag

    li $v0, 4
    la $a0, msg_done
    syscall

    mtc0 $zero, $13    # clear Cause
    jr $ra
    nop
