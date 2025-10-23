.text
.globl main

main:
    li $v0, 4
    la $a0, msg_start
    syscall

    # Enable global interrupts (Status)
    li   $t0, 0x0000FF11
    mtc0 $t0, $12

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

    end_sim:
    li $v0, 4
    la $a0, msg_end
    syscall

    li $v0, 10
    syscall