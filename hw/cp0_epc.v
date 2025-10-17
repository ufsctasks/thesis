// cp0_epc.v
// EPC Register (CP0 Reg 14)
module cp0_epc (
  input        clk,
  input        reset,
  input        activeexception,
  input  [31:0] i_adress,
  output reg [31:0] epc
);

  always @(posedge clk) begin
    if (reset)
      epc <= 32'b0;
    else if (activeexception)
      epc <= i_adress;  // salva o PC da instrução que causou exceção
  end

endmodule
