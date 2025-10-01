// cp0_cause.v
// CAUSE Register (CP0 Reg 13)
// Bits importantes: IP[15:8], ExcCode[6:2], TI (30)
module cp0_cause (
  input        clk,
  input        reset,
  input        activeexception,
  input  [4:0] exccode,
  input  [7:0] interrupts,  // IP[15:8]
  output reg [31:0] cause
);

  always @(posedge clk) begin
    if (reset) begin
      cause <= 32'b0;
    end
    else begin
      // IP bits são reflexo direto das linhas de IRQ + timer_pending
      cause[15:8] <= interrupts;
      // TI (bit 30) é reflexo do bit de timer pending
      cause[30]   <= interrupts[7];

      if (activeexception) begin
        cause[6:2] <= exccode;
        cause[1:0] <= 2'b00;
      end
    end
  end

endmodule
