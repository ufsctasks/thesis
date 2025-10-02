# Kernel Data Segment
.kdata 0x00003000         # base correta no Compact (Text@0)
flag:   .word 0

# Kernel Boot #################################
.ktext 0x00004000
__kernel_boot:
    mfc0   $t0, $12
    ori    $t0, $t0, 0x8001   # habilita IE e IM7
    mtc0   $t0, $12

    j main
    nop

# Exception Handler ############################
.ktext 0x00004180
handler:
    mfc0 $k0, $13
    srl  $t0, $k0, 2
    andi $t0, $t0, 0x1F   # ExcCode

    bne  $t0, $zero, not_interrupt
    nop

    # Checa IP7
    andi $t1, $k0, 0x8000
    beq  $t1, $zero, not_interrupt
    nop

    # --- Tratamento Timer ---
    li   $v0, 4
    la   $a0, msg_irq
    syscall

    mfc0 $t3, $9
    addiu $t3, $t3, 10000
    mtc0  $t3, $11        # reprograma Compare
    eret

not_interrupt:
    eret

.data
msg_irq: .asciiz "==> Interrupcao de Timer ocorreu!\n"
