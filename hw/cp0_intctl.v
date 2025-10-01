// cp0_intctl.v
// INTCTL Register (CP0 Reg 12 sel=1) - fixed value 0x68000020
module cp0_intctl (
  output [31:0] rdata
);
  assign rdata = 32'h68000020;
  //0110 1000 0000 0000 0000 0000 0010 0000
endmodule
