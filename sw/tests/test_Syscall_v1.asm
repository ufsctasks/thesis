# test_Syscall_v1.asm
# Teste real com syscall — sem handler_dispatch.
#
# $v0=4 e $v0=8 sao disparados via 'syscall' diretamente.
# No MARS, o simulador intercepta esses valores antes do handler,
# entao service_flag ficara 0 (INFO). Em hardware MIPS real,
# o handler seria invocado e a flag seria setada (OK).
#
# No Teste 2 ($v0=8), o MARS abre o campo de digitacao —
# digite qualquer texto e pressione Enter para continuar.
#
# Setup MARS:
#   1. Settings > Memory Configuration > Compact, Text at Address 0
#   2. Settings > Exception Handler > exception_handler_v1.asm
#   3. Assemble + Run

.data
msg_t1:      .asciiz "\n=== Teste 1: $v0=4 (print string) ===\n"
msg_t2:      .asciiz "\n=== Teste 2: $v0=8 (read string) ===\n"
msg_ok4:     .asciiz "[OK] handler capturou $v0=4 -> service_print\n"
msg_ok8:     .asciiz "[OK] handler capturou $v0=8 -> service_read\n"
msg_mars4:   .asciiz "[INFO] $v0=4 tratado pelo MARS (handler nao foi chamado)\n"
msg_mars8:   .asciiz "[INFO] $v0=8 tratado pelo MARS (handler nao foi chamado)\n"
msg_leu:     .asciiz "Texto lido: "
msg_end:     .asciiz "\n--- Fim do teste ---\n"

str_print:   .asciiz "<<< string passada como argumento $a0 >>>\n"
buf_read:    .space 64

.text
.globl main

main:
# ================================================================
# Teste 1: syscall com $v0 = 4 (print string)
# ================================================================
    li    $v0, 4
    la    $a0, msg_t1
    syscall

    # Zera service_flag
    li    $t0, 0
    sw    $t0, 0x00005000

    # Dispara syscall com $v0=4
    # Hardware MIPS: ExcCode=8 → handler → service_print → flag=4
    # MARS: imprime direto, flag fica 0
    li    $v0, 4
    la    $a0, str_print
    syscall

    lw    $t0, 0x00005000
    li    $t1, 4
    bne   $t0, $t1, mars4
    nop
    li    $v0, 4
    la    $a0, msg_ok4
    syscall
    j     test2
    nop
mars4:
    li    $v0, 4
    la    $a0, msg_mars4
    syscall

# ================================================================
# Teste 2: syscall com $v0 = 8 (read string)
# No MARS: abre campo de digitacao — digite algo e pressione Enter
# ================================================================
test2:
    li    $v0, 4
    la    $a0, msg_t2
    syscall

    # Zera service_flag
    li    $t0, 0
    sw    $t0, 0x00005000

    # Dispara syscall com $v0=8
    # Hardware MIPS: ExcCode=8 → handler → service_read → flag=8
    # MARS: aguarda digitacao do usuario, flag fica 0
    li    $v0, 8
    la    $a0, buf_read
    li    $a1, 64
    syscall                   # << MARS abre campo de digitacao aqui

    # Imprime o que foi lido (so funciona se MARS tratou direto)
    li    $v0, 4
    la    $a0, msg_leu
    syscall
    li    $v0, 4
    la    $a0, buf_read
    syscall

    lw    $t0, 0x00005000
    li    $t1, 8
    bne   $t0, $t1, mars8
    nop
    li    $v0, 4
    la    $a0, msg_ok8
    syscall
    j     done
    nop
mars8:
    li    $v0, 4
    la    $a0, msg_mars8
    syscall

# ================================================================
done:
    li    $v0, 4
    la    $a0, msg_end
    syscall
    li    $v0, 10
    syscall
