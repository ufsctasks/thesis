module coprocessor0(
  input         clk, reset,
  input         cp0_write_en,         // pulso MTC0
  input   [7:0] cp0_read_addr,  // mudar para 8 bits para sel
  input   [7:0] cp0_write_addr, 
  input   [31:0] cp0_write_data,        // dado vindo da ULA
  //input   [31:0] i_adress,
  input   [7:4] interrupts,        // IRQ externas, pinos 7 a 4

  // Condicoes sincronas sinalizadas pela unidade de controle do MIPS_S
  input         syscall,           // instrucao SYSCALL executada
  input         ri,                // instrucao reservada / nao implementada
  input         overflow,          // overflow aritmetico
  input         eret,              // instrucao ERET executada

  input         activeexception,   // CPU notifica que a excecao foi efetivada
  output reg [31:0] cop0readdata,
  output        pendingexception
);

  // --- sinais internos ---
  wire [31:0] status, cause, epc, count, compare;
  wire [4:0]  exccode;
  wire        iec;

  // === TIMER (Count/Compare) ===
  // Pulso de "hit" quando Count == Compare
  wire timer_hit = (count == compare); 

  // Latch que indica interrupção pendente do timer (IP[3])
  reg  timer_pending;

  always @(posedge clk) begin
    if (reset)
      timer_pending <= 1'b0;
    else if (cp0_write_en && (cp0_write_addr == 8'b01011000))
      timer_pending <= 1'b0;       // escrever Compare limpa pending
    else if (timer_hit)
      timer_pending <= 1'b1;       // seta quando Count == Compare
  end

  // === Vetor de interrupções (Cause[15:8] = IP[7:0]) ===
  // Bits mapeados conforme a convenção:
  // IP[7:4] → pinos externos (entrada do módulo)
  // IP[3]   → timer interno (Count/Compare)
  // IP[2]   → reservado (performance counters futuros)
  // IP[1:0] → reservados (software interrupts)
  wire [7:0] interrupts_with_timer;

  assign interrupts_with_timer[7:4] = interrupts;     // externas
  assign interrupts_with_timer[3]   = timer_pending;  // timer interno
  assign interrupts_with_timer[2]   = 1'b0;           // reservado
  assign interrupts_with_timer[1:0] = 2'b00;          // reservado


  // --- Unidade de exceções ---
  cp0_exception exception_unit (
    .iec(iec),
    .interrupts(interrupts_with_timer),
    .syscall(syscall),
    .ri(ri),
    .overflow(overflow),
    .pendingexception(pendingexception),
    .exccode(exccode)
  );

  // --- EPC ---
  cp0_epc epc_unit (
    .clk(clk),
    .reset(reset),
    .activeexception(activeexception),
    //.i_adress(i_adress),
    .epc(epc)
  );

  // --- STATUS ---
  cp0_status status_unit (
    .clk(clk),
    .reset(reset),
    .writeenable(cp0_write_en && (cp0_write_addr == 8'b01100000)),
    .activeexception(activeexception),
    .eret(eret),
    .writedata(cp0_write_data),
    .status(status),
    .iec(iec)
  );

  // --- CAUSE ---
  cp0_cause cause_unit (
    .clk(clk),
    .reset(reset),
    .activeexception(activeexception),
    .exccode(exccode),
    .ip_pending(interrupts_with_timer),
    .timer_pending(timer_pending),
    .cause(cause)
  );

  // --- COUNT ---
  cp0_count count_unit (
    .clk(clk),
    .reset(reset),
    .writeenable(cp0_write_en && (cp0_write_addr == 8'b01001000)),
    .writedata(cp0_write_data),
    .count(count)
  );

  // --- COMPARE ---
  cp0_compare compare_unit (
    .clk(clk),
    .reset(reset),
    .writeenable(cp0_write_en && (cp0_write_addr == 8'b01011000)),
    .writedata(cp0_write_data),
    .compare(compare)
  );

  // === IntCtl ===
  wire [31:0] intctl_value;
  cp0_intctl intctl_unit (
    .rdata(intctl_value)
  );

  // --- MFC0 (leitura) ---
  always @(*) begin
    case (cp0_read_addr)
      8'b01100000: cop0readdata = status;        // Status (12.0)
      8'b01100001: cop0readdata = intctl_value;  // IntCtl (12.1)
      8'b01101000: cop0readdata = cause;         // Cause (13.0)
      8'b01110000: cop0readdata = epc;           // EPC (14.0)
      8'b01001000: cop0readdata = count;         // Count (9.0)
      8'b01011000: cop0readdata = compare;       // Compare (11.0)
      default: cop0readdata = 32'hXXXXXXXX;
    endcase
  end

endmodule
