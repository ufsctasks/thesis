// cp0_cause.v
// CAUSE Register (CP0 Reg 13)
// Bits importantes: IP[15:8], ExcCode[6:2], TI (30)
module cp0_cause (
  input        clk,
  input        reset,
  input        activeexception,
  input  [4:0] exccode,
  input  [7:0] interrupts,  // IP[15:8]
  output reg [31:0] causereg
);

  always @(posedge clk) begin
    if (reset) begin
      causereg <= 32'b0;
    end
    else begin
      // IP bits são reflexo direto das linhas de IRQ + timer_pending
      causereg[15:8] <= interrupts;
      // TI (bit 30) é reflexo do bit de timer pending
      causereg[30]   <= interrupts[7];

      if (activeexception) begin
        causereg[6:2] <= exccode;
        causereg[1:0] <= 2'b00;
      end
    end
  end

endmodule
