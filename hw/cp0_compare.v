// cp0_compare.v
// COMPARE Register (CP0 Reg 11)
module cp0_compare (
  input        clk,
  input        reset,
  input        writeenable,
  input  [31:0] writedata,
  output reg [31:0] compare
);

  always @(posedge clk) begin
    if (reset)
      compare <= 32'b0;
    else if (writeenable)
      compare <= writedata;  // escrever limpa pending no coprocessor0.v
  end

endmodule
