// cp0_epc.v
// EPC Register (CP0 Reg 14)
module cp0_epc (
  input             clk,
  input             reset,
  input             activeexception, // CPU efetivou a excecao
  input             exl,             // Status.EXL: ja esta dentro de um handler?
  input      [31:0] pc,              // PC da instrucao que causou a excecao
  input             writeenable,     // MTC0 no EPC (handler faz EPC+4)
  input      [31:0] writedata,
  output reg [31:0] epc
);

  always @(posedge clk) begin
    if (reset)
      epc <= 32'b0;
    else if (activeexception && !exl)
      epc <= pc;          // 1) hardware salva o PC
    else if (writeenable)
      epc <= writedata;   // 2) software ajusta (EPC+4)
  end

endmodule
