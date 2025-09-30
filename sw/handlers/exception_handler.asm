# Memory map: Compact (MARS), Exception @ 0x00004180


# Kernel Data Segment
.kdata 0x00005000
.align 2
flag:   .word 0       # usado p/ sinalizar IRQ ao user

# Kernel Boot #################################
.ktext 0x00000000
__kernel_boot:
    # Habilita interrupções globais (IE=1) e do timer (IM7=1)
    mfc0   $t0, $12
    ori    $t0, $t0, 0x8001   # IM7 + IE
            # 1000 0000 0000 0001 
    li     $t1, 0xFFFD # 
            # 1111 1111 1111 1101
    and    $t0, $t0, $t1      # limpa EXL
    mtc0   $t0, $12

    j      main       # pula para user code
    nop

# Exception Handler############################
.ktext 0x00004180
handler:
    mfc0 $k0, $13        # Le Cause
    srl $t0, $k0, 2
    andi $t0, $t0, 0x1F  # ExcCode (5 bits)

    bne    $t0, $zero, not_interrupt
    nop

    # Checa IP7 (bit 15 de Cause)
    andi   $t1, $k0, 0x8000
    beq    $t1, $zero, not_interrupt
    nop

    # --- Tratamento Timer ---
    li     $t2, 1
    sw     $t2, flag

    mfc0   $t3, $9          # lê Count
    addiu  $t3, $t3, 10000
    mtc0   $t3, $11         # escreve Compare (limpa pending)
    eret

not_interrupt:
    eret
