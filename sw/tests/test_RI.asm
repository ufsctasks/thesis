.text
.globl main

main:
    li $v0, 4
    la $a0, msg_start
    syscall

    # Enable global interrupts (Status)
    li   $t0, 0x0000FF11
    mtc0 $t0, $12

 ri_case:
    li $v0, 4
    la $a0, msg_ri
   syscall
    la $t0, invalid_instr     
    jr $t0       
    li $t4, 0x00002800      # ExcCode = 10
    mtc0 $t4, $13             
    nop