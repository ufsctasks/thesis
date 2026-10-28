# Mapa de registradores do CP0 — MIPS_S_Cp0

Registradores de controle implementados, segundo o esquema de endereçamento
definido na reunião de 27/09/2025: os bits `[7:3]` do endereço carregam o número
do registrador e os bits `[2:0]` carregam o seletor.

| Registrador | Número.sel | Endereço codificado | Acesso | Função |
|---|---|---|---|---|
| Status  | 12.0 | `01100_000` | R/W | Modo de execução, habilitação global de interrupções (IE) e máscara (IM) |
| IntCtl  | 12.1 | `01100_001` | R   | Constante `0x68000020`; define o pino usado pelo timer (campo IPTI = 3) |
| Cause   | 13.0 | `01101_000` | R   | Causa da exceção (ExcCode), interrupções pendentes (IP) e flag do timer (TI) |
| EPC     | 14.0 | `01110_000` | R/W | Endereço de retorno da exceção |
| Count   |  9.0 | `01001_000` | R/W | Contador livre, incrementado a cada ciclo |
| Compare | 11.0 | `01011_000` | R/W | Valor de comparação; escrever reconhece a interrupção do timer |

## Campos utilizados

### Status (12.0)

| Bit(s) | Nome | Descrição |
|---|---|---|
| 0      | IE  | Habilitação global de interrupções |
| 1      | EXL | Nível de exceção; indica tratamento em curso |
| 15:8   | IM  | Máscara individual por linha de interrupção |

Comportamento: ao efetivar uma exceção, o hardware seta EXL e limpa IE. Ao
executar ERET, limpa EXL e restaura IE.

### Cause (13.0)

| Bit(s) | Nome    | Descrição |
|---|---|---|
| 6:2    | ExcCode | Código da exceção |
| 15:8   | IP      | Interrupções pendentes |
| 30     | TI      | Interrupção do timer pendente |

Códigos de exceção suportados:

| Valor | Mnemônico | Condição |
|---|---|---|
| 0  | Int | Interrupção externa ou do timer |
| 8  | Sys | Instrução SYSCALL |
| 10 | RI  | Instrução reservada ou não implementada |
| 12 | Ov  | Overflow aritmético |

## Alocação das linhas de interrupção

Conforme decidido na reunião de 27/09/2025:

| Linha | Origem | Alocação |
|---|---|---|
| IP[7:4] | Pinos externos | Periféricos ou futuro controlador de interrupções |
| IP[3]   | Interno | Timer, gerado pelo par Count/Compare |
| IP[2]   | Reservado | Contadores de desempenho, não implementados |
| IP[1:0] | Reservado | Traps condicionais, não implementadas |

Apenas as quatro linhas superiores correspondem a pinos físicos, motivo pelo
qual a entrada `interrupts` do módulo de topo é declarada como `[7:4]`.

---

# Histórico de alterações no RTL

## 2026-10-28 — Revisão completa e implementação do EPC

### Revisão do CP0

Revisão de todos os módulos (`hw/`), do testbench existente e dos programas em
`sw/`, com simulação em Icarus Verilog 12. Antes da correção, os dois
testbenches passavam (22/22 verificações em `cp0_count_compare_tb.sv`), mas um
teste de sondagem dirigido aos pontos não cobertos mostrou:

| Caso de teste | Resultado obtido | Esperado (MIPS32) |
|---|---|---|
| `MTC0` em EPC com `0x1234` | EPC = `0x00000000` | `0x00001234` |
| IE = 1, IM = `0x00`, IRQ em IP[7] | `pendingexception` = 1 | 0 (linha mascarada) |
| `syscall` baixa antes do ciclo de `activeexception` | ExcCode = 0 | 8 |
| IE = 0 antes da exceção, depois ERET | IE = 1 | IE inalterado |
| `MFC0` de registrador não implementado | `0xXXXXXXXX` | valor definido (0) |

### 1. `cp0_epc.v` — captura do PC e escrita por MTC0

Problema: o registrador não tinha caminho de dados. A captura estava comentada
(o EPC permanecia em zero) e não havia entrada de escrita, de modo que o
`mtc0 $k0, $14` usado pelos tratadores para avançar o EPC era ignorado.
Consequências: o ERET retornava sempre ao endereço `0x00000000` e, mesmo com a
captura corrigida, exceções síncronas (SYSCALL, RI, Ov) voltariam para a própria
instrução causadora, repetindo a exceção indefinidamente.

Correções aplicadas:

- Nova entrada `pc [31:0]` no `cp0_epc` e no módulo de topo, por onde o MIPS_S
  fornece o endereço da instrução que causa a exceção. Substitui a proposta de
  17/10/2025 de multiplexar o PC com a saída da ALU na interface de escrita: a
  porta dedicada tem o mesmo efeito, com controle mais simples. **Mudança a
  comunicar à orientação.**
- Captura `EPC <- pc` no ciclo de `activeexception`, **somente se
  `Status.EXL = 0`**. Uma exceção ocorrida dentro do tratador não sobrescreve o
  endereço de retorno original, como na MIPS32.
- Escrita por MTC0 no endereço `01110_000` (14.0), habilitando o ajuste
  `EPC <- EPC + 4` pelo software.
- Prioridade: reset > captura por exceção > escrita por MTC0.

Verificação (seção [10] de `cp0_count_compare_tb.sv` e `tb_coprocessor0.v`):

| Cenário | EPC obtido |
|---|---|
| SYSCALL em `0x40` | `0x00000040` |
| Segunda exceção dentro do tratador (EXL = 1), PC = `0x4188` | `0x00000040` (preservado) |
| Tratador executa `mtc0` com EPC + 4 | `0x00000044` |
| RI em `0x100` / Ov em `0x204`, seguidos de EPC + 4 | `0x104` / `0x208` |
| Interrupção do timer com PC = `0x500` | `0x00000500` |

Resultado: `cp0_count_compare_tb.sv` 26/26 verificações aprovadas;
`tb_coprocessor0.v` 0 erros.

### 2. Testbenches

- `cp0_count_compare_tb.sv`: ligada a nova porta `pc` e adicionada a seção
  [10] (captura do PC, proteção por EXL, escrita por MTC0, ERET).
- `tb/tb_coprocessor0.v` (novo): teste unitário de todas as causas — SYSCALL,
  RI e Ov com verificação de ExcCode, EXL e EPC; timer; interrupção externa;
  mascaramento por IE.

### Contrato de interface com o MIPS_S (a respeitar na integração)

- `pc` deve carregar o endereço da instrução que causou a exceção (ou da
  instrução interrompida, no caso de interrupção) no ciclo de `activeexception`.
- `syscall`, `ri` e `overflow` devem permanecer ativos até o ciclo de
  `activeexception`, inclusive; o ExcCode é amostrado nesse ciclo.
- No ERET, o MIPS_S carrega o PC com o valor do EPC (hoje disponível apenas via
  `cop0readdata`; avaliar porta dedicada `epc` na integração).

## 2026-09-12 — Correção de defeitos bloqueantes

Revisão do RTL antes da escrita do primeiro testbench. Os itens 1 a 3 impediam
a compilação ou produziam ligações inválidas.

### 1. `cp0_exception.v` — entradas não declaradas

Os sinais `iec`, `syscall`, `ri`, `overflow` e `divzero` eram usados no corpo do
módulo, mas estavam comentados na lista de portas. O uso de identificadores não
declarados dentro de um bloco `always` é erro de compilação.

Correções aplicadas:

- Declaradas as entradas `iec`, `syscall`, `ri` e `overflow`.
- `always @(interrupt)` substituído por `always @(*)`, pois a lista de
  sensibilidade anterior não cobria as demais condições.
- `pendingexception` passou a considerar também as condições síncronas, e não
  somente a interrupção.
- Removido o tratamento de `divzero` com código 15. Divisão inteira por zero não
  gera exceção na arquitetura MIPS, e o código 15 corresponde a exceção de ponto
  flutuante. **Ponto a confirmar com a orientação.**

### 2. `cp0_cause.v` — incompatibilidade de portas

O módulo declarava `interrupts [7:4]` e `timer_pending` como entradas separadas
e remontava o vetor IP internamente. O módulo de topo, porém, já montava o vetor
completo e o passava inteiro para a porta de 4 bits, deixando `timer_pending`
desconectada.

Correções aplicadas:

- A porta passou a ser `ip_pending [7:0]`, recebendo o vetor já montado pelo topo.
- `timer_pending` permanece como entrada, usada apenas para refletir o bit TI.
- Eliminada a montagem duplicada do vetor.

Observação: a definição de `[7:4]` acordada em 27/09/2025 refere-se aos **pinos
externos do módulo de topo**, que permanecem inalterados. Esta mudança afeta
apenas a interface interna entre `coprocessor0` e `cp0_cause`.

### 3. `coprocessor0.v` — entradas ausentes

O módulo conectava `.eret(eret)` ao `cp0_status`, mas `eret` estava comentado na
lista de portas, resultando em fio sem driver. O caminho de retorno de exceção
nunca era exercitado: o IE seria zerado na primeira interrupção e jamais
restaurado.

Correções aplicadas:

- Declaradas as entradas `syscall`, `ri`, `overflow` e `eret`.
- Corrigida a instanciação de `cp0_cause`.
- `always` de leitura (MFC0) alterado para `always @(*)`.

---

# Pendências identificadas

## Bloqueante para o ciclo completo de exceção

~~**`cp0_epc.v` não possui caminho de dados.**~~ Resolvido em 2026-10-28 (ver
histórico).

## Identificados na revisão de 2026-10-28

- **ExcCode depende do instante de `activeexception`.** O código é
  combinacional e só é registrado no ciclo de `activeexception`; se a condição
  síncrona já tiver sido retirada, o Cause recebe 0. Tratado por ora como
  contrato de interface; alternativa é registrar o código quando
  `pendingexception` sobe.
- **MFC0 de registrador não implementado devolve `X`.** Na simulação integrada o
  valor indefinido se propaga ao banco de registradores. Sugestão:
  `default: cop0readdata = 32'h0;`.
- **Pinos `interrupts` sem sincronizador.** Entram direto em lógica
  combinacional; em FPGA, com fonte assíncrona, exigem dois flip-flops.
- **Documentação divergente do RTL.** O README cita IntCtl `0x68000010` (o
  correto é `0x68000020`), lista Divide by Zero (15), e afirma que a pendência
  considera `EXL = 0` e `IP & IM`, o que o hardware ainda não faz.
- **Programas em `sw/tests`.** `test_Overflow`, `test_RI`, `test_Syscall` e
  `test_countCompar_full_sw` usam rótulos inexistentes e não montam sozinhos;
  `test_handler.asm` simula a exceção em software (`mtc0` no Cause +
  `jal handler`) sem passar pelo CP0; `exception_handler.asm` usa IP[7] (bit 15)
  para o timer, que está em IP[3] (bit 11); `test_divBy_zero.asm` está vazio.
  Funcionais: `test_timer_irq.asm` e o par `exception_handler_v1.asm` +
  `test_Syscall_v1.asm`.

## Pontos a confirmar com a orientação

1. **Disparo espúrio do timer após o reset — confirmado por simulação.**
   `timer_hit` é `(count == compare)`, e ambos valem zero ao sair do reset, de
   modo que `timer_pending` é setado sem que o timer tenha sido programado. O
   testbench `tb/cp0_count_compare_tb.sv` reporta `Cause.IP[3] = 1` três ciclos
   após o reset.

   Consequência prática: se o código de boot habilitar o IE antes de escrever no
   Compare, uma interrupção de timer ocorre imediatamente, sem solicitação do
   software.

   Alternativas:
   - inicializar Compare com `0xFFFFFFFF` no reset (uma linha em `cp0_compare.v`);
   - exigir que o boot escreva Compare antes de habilitar interrupções, tornando
     isso um requisito documentado do software — é o comportamento do MIPS real;
   - qualificar `timer_hit` com um bit de armação, setado na primeira escrita ao
     Compare.

2. **ERET força `IE = 1`.** Confirmado por simulação em 2026-10-28 (Status
   `0xE0` antes da exceção, `0xE1` após ERET). Na MIPS32, ERET limpa EXL e a habilitação efetiva
   decorre do IE previamente existente. A implementação atual seta IE
   incondicionalmente, o que reabilita interrupções mesmo que estivessem
   desabilitadas de propósito antes da exceção.

3. **Campos KX, SX e UX no Status.** Os bits 7, 6 e 5 são setados no reset, mas
   pertencem à MIPS64; na MIPS32 são reservados. Verificar se é intencional ou
   herança do código do Harvey Mudd College.

4. **Count incrementa a cada ciclo.** No MIPS real o incremento ocorre a cada
   dois ciclos. A diferença afeta o cálculo de intervalos pelo software.

5. **Campo IM não é consultado pelo hardware.** O `cp0_exception.v` avalia apenas
   `iec & (|interrupts)`, sem mascaramento individual por linha. O software
   programa a máscara por conformidade, mas ela não tem efeito. Confirmado por
   simulação em 2026-10-28: IE = 1, IM = `0x00` e IRQ em IP[7] geram exceção.
