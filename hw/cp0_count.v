// cp0_count.v
// COUNT Register (CP0 Reg 9)
module cp0_count (
  input        clk,
  input        reset,
  input        writeenable,
  input  [31:0] writedata,
  output reg [31:0] count
);

  always @(posedge clk) begin
    if (reset)
      count <= 32'b0;
    else if (writeenable)
      count <= writedata;
    else
      count <= count + 1;
  end

endmodule
