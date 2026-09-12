# ============================================================================
# test_timer_irq.asm
#
# Teste do par Count/Compare do Cp0, conforme orientacao de 29/09/2025:
#   "Faz um programa de teste a nivel de usuario que leia o valor do Count,
#    some uns 1.000 ou 10.000 ao valor lido, escreva no Compare, e depois
#    entra em um laco esperando que a interrupcao ocorra. Depois, escreve o
#    codigo de atendimento da interrupcao no nivel do kernel."
#
# O arquivo e autocontido: inclui o codigo de boot, o programa de usuario e
# o tratador de excecoes, cada um no seu segmento.
#
# ---------------------------------------------------------------------------
# Setup no MARS:
#   1. Settings > Memory Configuration > Compact, Text at Address 0
#   2. Rodar diretamente (o handler esta neste mesmo arquivo, em .ktext)
#
# ATENCAO - limitacao do MARS:
#   O MARS nao implementa os registradores Count ($9) e Compare ($11), nem
#   gera a interrupcao do timer. Neste simulador o programa executa ate o
#   laco de espera e nao progride. A validacao efetiva deste teste e feita
#   por simulacao de hardware, onde o Cp0 real gera a interrupcao.
#
# ---------------------------------------------------------------------------
# Mapa de memoria (modelo compacto):
#   0x00000000  texto do usuario
#   0x00002000  dados do usuario
#   0x00004000  texto do kernel (boot)
#   0x00004180  tratador de excecoes
#   0x00005000  dados do kernel
# ============================================================================

# ---------------------------------------------------------------------------
# Parametros do teste
# ---------------------------------------------------------------------------
    .eqv  TIMER_INTERVAL, 10000    # ciclos ate a interrupcao
    .eqv  TICKS_ESPERADOS, 3       # quantas interrupcoes o teste aguarda

    .eqv  CP0_COUNT,   $9
    .eqv  CP0_COMPARE, $11
    .eqv  CP0_STATUS,  $12
    .eqv  CP0_CAUSE,   $13
    .eqv  CP0_EPC,     $14

# ---------------------------------------------------------------------------
# Dados do usuario
# ---------------------------------------------------------------------------
.data 0x00002000
msg_start:  .asciiz "== Teste Count/Compare ==\n"
msg_armed:  .asciiz "Timer armado. Aguardando interrupcao...\n"
msg_done:   .asciiz "Todas as interrupcoes recebidas. Teste concluido.\n"

# ---------------------------------------------------------------------------
# Dados do kernel
# ---------------------------------------------------------------------------
.kdata 0x00005000
    .align 2
tick_count:   .word 0    # numero de interrupcoes do timer atendidas
saved_t0:     .word 0    # area de salvamento usada pelo handler
saved_t1:     .word 0

# ---------------------------------------------------------------------------
# Boot do kernel
#
# Executado imediatamente apos o reset. Inicializa os registradores de
# controle do Cp0 e transfere o controle ao programa de usuario.
# ---------------------------------------------------------------------------
.ktext 0x00004000
__boot:
    # Zera o contador de ticks
    li    $k0, 0
    sw    $k0, tick_count

    # Programa Status: habilita interrupcoes (IE) e desmascara IM[3],
    # que e a linha usada pelo par Count/Compare.
    #   bit  0  = IE    (habilitacao global)
    #   bit 11  = IM[3] (mascara da linha 3)
    # Observacao: o hardware atual nao consulta o campo IM; a mascara e
    # programada aqui por conformidade com a MIPS32.
    li    $k0, 0x00000801
    mtc0  $k0, CP0_STATUS

    # Salta para o programa de usuario
    j     main
    nop

# ---------------------------------------------------------------------------
# Programa de usuario
# ---------------------------------------------------------------------------
.text 0x00000000
    .globl main
main:
    li    $v0, 4
    la    $a0, msg_start
    syscall

    # --- Arma o timer -------------------------------------------------------
    # Le o Count corrente, soma o intervalo desejado e escreve no Compare.
    # A escrita no Compare tambem reconhece qualquer pendencia anterior.
    mfc0  $t0, CP0_COUNT
    addiu $t0, $t0, TIMER_INTERVAL
    mtc0  $t0, CP0_COMPARE

    li    $v0, 4
    la    $a0, msg_armed
    syscall

    # --- Aguarda as interrupcoes -------------------------------------------
    # O laco compara o contador mantido pelo kernel com o numero esperado.
    # Nada dentro do laco altera tick_count: a unica forma de sair dele e
    # o tratador de interrupcao incrementar a variavel.
    li    $s0, TICKS_ESPERADOS

wait_loop:
    lw    $t1, tick_count
    bge   $t1, $s0, test_done
    nop
    j     wait_loop
    nop

test_done:
    li    $v0, 4
    la    $a0, msg_done
    syscall

    li    $v0, 10          # encerra a execucao
    syscall

# ---------------------------------------------------------------------------
# Tratador de excecoes
#
# Ponto de entrada fixo do modelo compacto. Determina a causa, atende, e
# retorna. Usa $k0 e $k1, reservados ao kernel, e salva os demais registradores
# que precisar em area propria.
# ---------------------------------------------------------------------------
.ktext 0x00004180
handler:
    # --- Identifica a causa -------------------------------------------------
    mfc0  $k0, CP0_CAUSE
    srl   $k0, $k0, 2
    andi  $k0, $k0, 0x1F       # $k0 = ExcCode

    beq   $k0, $zero, trata_interrupcao
    nop

    li    $k1, 8
    beq   $k0, $k1, trata_syscall
    nop

    j     causa_nao_tratada
    nop

# --- ExcCode 0: interrupcao -------------------------------------------------
trata_interrupcao:
    # Verifica se a origem foi o timer, inspecionando Cause.IP[3],
    # que corresponde ao bit 11 do registrador.
    mfc0  $k0, CP0_CAUSE
    andi  $k0, $k0, 0x0800
    beq   $k0, $zero, irq_externa
    nop

# --- Interrupcao do timer ---------------------------------------------------
irq_timer:
    sw    $t0, saved_t0
    sw    $t1, saved_t1

    # Incrementa o contador de ticks
    lw    $t0, tick_count
    addiu $t0, $t0, 1
    sw    $t0, tick_count

    # Rearma o timer para o proximo intervalo. A escrita no Compare
    # tambem reconhece a interrupcao corrente, limpando o pendente.
    mfc0  $t1, CP0_COUNT
    addiu $t1, $t1, TIMER_INTERVAL
    mtc0  $t1, CP0_COMPARE

    lw    $t0, saved_t0
    lw    $t1, saved_t1

    j     retorno_interrupcao
    nop

# --- Interrupcao externa, ainda sem tratamento especifico -------------------
irq_externa:
    j     retorno_interrupcao
    nop

# --- ExcCode 8: chamada de sistema ------------------------------------------
trata_syscall:
    # Este teste nao exercita servicos de sistema; a chamada apenas retorna.
    j     retorno_syscall
    nop

# --- Causa nao prevista -----------------------------------------------------
causa_nao_tratada:
    j     retorno_syscall
    nop

# ---------------------------------------------------------------------------
# Retornos
#
# A distincao entre os dois e essencial e decorre do significado do EPC:
#
#   Interrupcao  - o EPC aponta para a instrucao que NAO chegou a executar,
#                  pois foi interrompida. O retorno deve reexecuta-la, logo
#                  o EPC nao e alterado.
#
#   Excecao sincrona - o EPC aponta para a propria instrucao que causou a
#                  excecao. Retornar sem avancar faria o programa reexecuta-la
#                  indefinidamente, logo soma-se 4 ao EPC.
# ---------------------------------------------------------------------------
retorno_interrupcao:
    eret

retorno_syscall:
    mfc0  $k0, CP0_EPC
    addiu $k0, $k0, 4
    mtc0  $k0, CP0_EPC
    eret
