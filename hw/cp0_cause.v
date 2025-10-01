// cp0_cause.v
// CAUSE Register (CP0 Reg 13)
// Bits importantes: IP[15:8], ExcCode[6:2], TI (30)

module cp0_cause (
  input        clk,
  input        reset,
  input        activeexception,   // sinal do controle
  input  [4:0] exccode,           // código da exceção
  input  [7:4] interrupts,    // entradas externas (IP[7:4])
  input        timer_pending,     // sinal interno do Timer (IP[3])
  output reg [31:0] cause
);

  always @(posedge clk) begin
    if (reset) begin
      cause <= 32'b0;
    end
    else begin
      // IP[15:8] = {interrupts, timer_pending, 3'b000}
      cause[15:8] <= {interrupts, timer_pending, 3'b000};

      // TI (bit 30) reflete o pending do timer
      cause[30]   <= timer_pending;

      // Se uma exceção está ativa, atualiza ExcCode
      if (activeexception) begin
        cause[6:2] <= exccode;
        cause[1:0] <= 2'b00;  // bits reservados
      end
    end
  end

endmodule
