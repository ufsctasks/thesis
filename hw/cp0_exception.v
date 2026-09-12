// cp0_exception.v
// Exception logic for interrupts, syscall, RI, overflow
//
// Determina se existe uma excecao pendente e qual o seu codigo (ExcCode),
// segundo a prioridade definida pela arquitetura MIPS32.
module cp0_exception (
  input        iec,            // Status[0] - habilitacao global de interrupcoes
  input  [7:0] interrupts,     // IP[7:0] (externos + timer interno)

  input        syscall,        // instrucao SYSCALL executada
  input        ri,             // instrucao reservada / nao implementada
  input        overflow,       // overflow aritmetico

  output reg   pendingexception,
  output reg [4:0] exccode
);

  // Interrupcao ocorre se a habilitacao global estiver ligada
  // e existir pelo menos um pedido pendente em IP.
  wire interrupt = iec & (|interrupts);

  always @(*) begin
    // Ha excecao pendente se houver interrupcao habilitada ou
    // qualquer condicao sincrona gerada pela instrucao corrente.
    pendingexception = interrupt | syscall | ri | overflow;

    if (interrupt)
      exccode = 5'd0;       // Int      - interrupcao externa ou do timer
    else if (syscall)
      exccode = 5'd8;       // Sys      - chamada de sistema
    else if (ri)
      exccode = 5'd10;      // RI       - instrucao reservada
    else if (overflow)
      exccode = 5'd12;      // Ov       - overflow aritmetico
    else
      exccode = 5'd0;       // valor de repouso
  end

endmodule
