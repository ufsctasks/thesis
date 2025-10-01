.data
msg_start: .asciiz "\n== Testando Count/Compare (Timer) ==\n"
msg_wait:  .asciiz "Aguardando interrupcao do timer...\n"
msg_done:  .asciiz "Interrupcao tratada pelo handler!\n"

.text
.globl main
main:
    # Mensagem inicial
    li $v0, 4
    la $a0, msg_start
    syscall

    # Zera flag
    li $t0, 0
    sw $t0, flag

    # Programa Compare = Count + 10000
    mfc0 $t1, $9         # lê Count
    addiu $t1, $t1, 10000
    mtc0 $t1, $11        # escreve Compare

    # Mensagem de espera
    li $v0, 4
    la $a0, msg_wait
    syscall

wait_loop:
    lw $t2, flag
    beq $t2, $zero, wait_loop
    nop

    # Quando flag != 0 → handler foi chamado
    li $v0, 4
    la $a0, msg_done
    syscall

    li $v0, 10
    syscall
