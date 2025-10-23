.text
.globl main

# MAIN
main:
    li $v0, 4
    la $a0, msg_start
    syscall

    # Enable global interrupts (Status)
    li   $t0, 0x0000FF11
    mtc0 $t0, $12

syscall_case:
    li $v0, 4
    la $a0, msg_syscall
    syscall
    li $t4, 0x00002000      # ExcCode = 8
    mtc0 $t4, $13
    syscall         

    end_sim:
    li $v0, 4
    la $a0, msg_end
    syscall

    li $v0, 10
    syscall