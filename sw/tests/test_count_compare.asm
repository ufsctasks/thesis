.data
msg_start: .asciiz "\n== Testando Count/Compare (Timer) ==\n"
msg_wait:  .asciiz "Aguardando interrupcao do timer...\n"
msg_done:  .asciiz "Interrupcao do timer tratada!\n"

.text
.globl main
main:
    # Imprime cabecalho
    li $v0, 4
    la $a0, msg_start
    syscall

    # Zera Count
    li $t0, 0
    mtc0 $t0, $9          # CP0 reg 9 = Count

    # Configura Compare para disparar depois de alguns ciclos
    li $t0, 50
    mtc0 $t0, $11         # CP0 reg 11 = Compare

    li $v0, 4
    la $a0, msg_wait
    syscall

loop:
    # Le Count e compara com Compare só para debug
    mfc0 $t1, $9          # lê Count
    mfc0 $t2, $11         # lê Compare
    blt $t1, $t2, loop    # espera até count >= compare

    # Depois da interrupção, o handler vai ser chamado
    # e fazer eret. Continuamos daqui.
    li $v0, 4
    la $a0, msg_done
    syscall

    li $v0, 10
    syscall
