// cp0_exception.v
// Exception logic for syscall, RI, overflow, div0
module cp0_exception (
  input        syscall,
  input        ri,
  input        iec,
  input  [7:0] interrupts,   // IP[7:0] (externos + timer)

  // futuros:
  input        overflow,
  input        divzero,

  output reg   pendingexception,
  output reg [4:0] exccode
);

  // Interrupção ocorre se global IE estiver ligado e existir algum IP ativo
  wire interrupt = iec & (|interrupts);

  always @(interrupt | overflow | divzero | syscall | ri) begin
    pendingexception = interrupt | overflow | divzero | syscall | ri;

    if (interrupt)
      exccode = 5'b00000; // Interrupt
    else if (overflow)
      exccode = 5'b01100; // Overflow (12)
    else if (divzero)
      exccode = 5'b01111; // Div by Zero (15)
    else if (syscall)
      exccode = 5'b01000; // Syscall (8)
    else if (ri)
      exccode = 5'b01010; // RI (10)
    else
      exccode = 5'b00000; // default
  end

endmodule
