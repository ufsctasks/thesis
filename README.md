# MIPS_S CP0 – Extensão com Suporte a Interrupções e Exceções

Este projeto implementa uma **extensão do Coprocessador 0 (CP0)** para o núcleo educacional **MIPS_S**, adicionando suporte a **exceções precisas** e **tratamento de interrupções**.

---

##  Objetivo

O projeto visa permitir que o núcleo MIPS_S tenha suporte básico para:

- **Tratamento de exceções**: salvar EPC, preencher Cause, setar EXL e desviar para o vetor padrão.
- **Tratamento de interrupções**: habilitar globalmente (IE), mascarar linhas (IM), sinalizar pendência (Cause.IP) e disparar fluxo de exceção.

### Tipos de exceção implementados

- **8 – Syscall Exception**  
- **10 – Reserved Instruction Exception**  
- **12 – Arithmetic Overflow Exception**  
- **15 – Divide by Zero Exception**  

---

##  Componentes do Projeto

### Registradores do CP0 Implementados

| Registrador | Nº | Função |
|------------|----|--------|
| **Status (SR)** | 12 | Bit **IE** (Interrupt Enable), bit **EXL** (Exception Level) e máscara de interrupções **IM7..0**. |
| **Cause** | 13 | Campo **ExcCode** (bits 6..2), **IP7..0** (interrupções pendentes), **TI** (Timer Interrupt Pending). |
| **EPC** | 14 | Endereço da instrução que causou a exceção/interrupção. |
| **Count** | 9 | Contador de 32 bits, incrementado a cada ciclo. |
| **Compare** | 11 | Gera interrupção quando `Count == Compare`. Escrever nele limpa a pendência. |
| **IntCtl** | 12 sel=1 | Valor fixo `0x68000010`, configura **IPTI=3**, **IPPCI=2**, **VS=00001**. |

---

### Lógica de Interrupção e Exceção

- **pendingexception** é assertado quando:  
  `Status.IE = 1` **e** `Status.EXL = 0` **e** `(Cause.IP & Status.IM) ≠ 0`.
- **EPC** recebe PC da instrução vítima (ou do branch anterior se em delay slot).
- **Cause.ExcCode** recebe o código da exceção.
- **Cause.IP3** é setado quando `Count == Compare`.
- Ao escrever em **Compare**, o bit de pendência do timer é limpo.
- **eret** retorna de exceção: PC ← EPC e limpa SR(EXL).

---

### Handlers em Assembly

- Implementados na seção `.ktext 0x80000180`.
- Salvam registradores temporários (k0/k1).
- Lêem Cause e Status para identificar origem da exceção.
- Tratam exceção ou IRQ, imprimem mensagem (quando aplicável).
- Avançam EPC (+4) para evitar reexecução da instrução causadora.
- Restauram registradores e executam `eret`.

---

##  Testes e Demonstrações

- **Teste de Timer**
  - Inicializa `Count` e `Compare`, habilita IM3 em Status e aguarda IRQ.
  - Handler imprime mensagem, reprograma Compare e retorna ao laço principal.

- **Teste de Exceções**
  - Provoca exceções 8, 10, 12 e 15 em sequência.
  - Valida que cada uma é capturada, que EPC é atualizado e que o programa continua normalmente após `eret`.

---

##  Estrutura do Repositório



