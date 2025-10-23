.text
.globl main

main:
    li $v0, 4
    la $a0, msg_start
    syscall

    # Enable global interrupts (Status)
    li   $t0, 0x0000FF11
    mtc0 $t0, $12

# TEST 1: Timer interrupt (Count == Compare)

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

    end_sim:
    li $v0, 4
    la $a0, msg_end
    syscall

    li $v0, 10
    syscall