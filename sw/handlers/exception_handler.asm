.ktext 0x80000180
handler:
    mfc0 $k0, $13        # Le Cause
    srl $t0, $k0, 2
    andi $t0, $t0, 0x1F  # ExcCode (5 bits)

    # Mostra o codigo da excecao
    li $v0, 1
    move $a0, $t0
    syscall

    # Avanca EPC para evitar repetir a mesma instrucao
    mfc0 $k0, $14
    addiu $k0, $k0, 4
    mtc0 $k0, $14

    eret
