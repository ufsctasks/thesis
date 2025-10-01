.data
msg_start: .asciiz "\n== Testando Count/Compare (Timer) ==\n"
msg_wait:  .asciiz "Aguardando interrupcao do timer...\n"
msg_done:  .asciiz "Interrupcao do timer tratada (Handler)!\n"

.text
.globl main
main:
    # mensagem inicial
    li $v0, 4
    la $a0, msg_start
    syscall

    # lê Count e programa Compare = Count + 10000
    mfc0 $t0, $9         # lê Count
    addiu $t0, $t0, 10000
    mtc0 $t0, $11        # grava Compare

    # avisa que está aguardando
    li $v0, 4
    la $a0, msg_wait
    syscall

wait_loop:
    j wait_loop          # espera pela IRQ do timer
    nop
