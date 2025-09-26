// cp0_status.v
// STATUS Register (CP0 Reg 12, sel=0)
// Bits importantes: IE (0), EXL (1), IM[15:8]
module cp0_status (
  input        clk,
  input        reset,
  input        writeenable,      // MTC0 habilitado para Status
  input        activeexception,  // exceção detectada
  input        eret,             // return from exception
  input  [31:0] writedata,

  output reg [31:0] statusreg,
  output            iec          // bit IE (global interrupt enable)
);

  always @(posedge clk) begin
    if (reset) begin
      statusreg <= 32'b0;
      statusreg[7] <= 1'b1; // KX
      statusreg[6] <= 1'b1; // SX
      statusreg[5] <= 1'b1; // UX
      statusreg[4:3] <= 2'b00; // KSU = kernel mode
    end 
    else if (activeexception) begin
      statusreg[1] <= 1'b1;      // seta EXL
      statusreg[0] <= 1'b0;      // desabilita interrupções
    end
    else if (eret) begin
      statusreg[1] <= 1'b0;      // limpa EXL
      statusreg[0] <= 1'b1;      // reabilita interrupções
    end
    else if (writeenable) begin
      statusreg <= writedata;
    end
  end

  assign iec = statusreg[0];

endmodule
