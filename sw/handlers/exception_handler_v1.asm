# exception_handler_v1.asm
# Versao simples: handler que trata SYSCALL (ExcCode=8)
# e despacha para $v0=4 (print string) ou $v0=8 (read string).
#
# Sem handler_dispatch — usa apenas o mecanismo real de excecao.
# service_flag em 0x00005000 registra qual servico foi chamado.
#
# Setup MARS:
#   1. Settings > Memory Configuration > Compact, Text at Address 0
#   2. Settings > Exception Handler > este arquivo
#   3. Abrir test_Syscall_v1.asm e rodar

# ---- Kernel Data ------------------------------------------------
.kdata 0x00005000
.align 2
service_flag: .word 0    # 4 = print string, 8 = read string, 0 = nenhum
saved_t0:     .word 0    # salva $t0 durante o handler

# ---- Kernel Boot ------------------------------------------------
.ktext 0x00004000
__kernel_boot:
    mfc0  $k0, $12
    ori   $k0, $k0, 0x0001   # IE = 1
    li    $k1, 0xFFFD
    and   $k0, $k0, $k1      # limpa EXL
    mtc0  $k0, $12
    j     main
    nop

# ---- Exception Handler @ 0x00004180 ----------------------------
.ktext 0x00004180
handler:
    # 1. Extrai ExcCode de Cause[6:2]
    mfc0  $k0, $13
    srl   $k0, $k0, 2
    andi  $k0, $k0, 0x1F

    # 2. Verifica ExcCode == 8 (SYSCALL)
    li    $k1, 8
    bne   $k0, $k1, not_syscall
    nop

    # 3. Despacha com base em $v0
    li    $k1, 4
    beq   $v0, $k1, service_print
    nop
    li    $k1, 8
    beq   $v0, $k1, service_read
    nop
    j     syscall_unknown
    nop

# --- $v0 = 4: print string --------------------------------------
service_print:
    sw    $t0, saved_t0        # salva $t0
    move  $t0, $a0             # $t0 = ponteiro para a string
    li    $k1, 0x7F00          # $k1 = endereço UART TX
print_loop:
    lb    $k0, 0($t0)          # carrega byte atual
    sb    $k0, 0($k1)          # envia para UART (inclusive o '\0')
    beq   $k0, $zero, print_done
    nop
    addiu $t0, $t0, 1
    j     print_loop
    nop
print_done:
    lw    $t0, saved_t0        # restaura $t0
    j     advance_epc
    nop

# --- $v0 = 8: read string ---------------------------------------
service_read:
    li    $k0, 0x00005000
    li    $k1, 8
    sw    $k1, 0($k0)         # service_flag = 8
    j     advance_epc
    nop

# --- $v0 desconhecido -------------------------------------------
syscall_unknown:
    li    $k0, 0x00005000
    sw    $v0, 0($k0)
    j     advance_epc
    nop

# --- Avanca EPC+4 e retorna -------------------------------------
advance_epc:
    mfc0  $k0, $14
    addiu $k0, $k0, 4
    mtc0  $k0, $14
    eret

# --- Nao era SYSCALL --------------------------------------------
not_syscall:
    mfc0  $k0, $14
    addiu $k0, $k0, 4
    mtc0  $k0, $14
    eret
