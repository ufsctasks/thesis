module coprocessor0(
  input         clk, reset,

  input   [7:0] interrupts,        // IRQ externas

  input         cop0write,         // pulso MTC0
  input   [4:0] cp0_readaddress, 
  input   [4:0] cp0_writeaddress,
  input   [31:0] writecop0,        // dado vindo da ULA
  input   [31:0] pc,
  input         syscall,  
  input         ri,                // reserved instruction
  // entradas futuras:
   input         overflow,
   input         divzero,

  input         eret,              // return from exception
  input         activeexception,
  output reg [31:0] cop0readdata,
  output        pendingexception
);

  // --- sinais internos ---
  wire [31:0] statusreg, causereg, epc, count, compare;
  wire [4:0]  exccode;
  wire        iec;

  // === TIMER (Count/Compare) ===
  wire timer_hit = (count == compare);
  reg  timer_pending;

  always @(posedge clk) begin
    if (reset)
      timer_pending <= 1'b0;
    else if (cop0write && (cp0_writeaddress == 5'b01011))
      timer_pending <= 1'b0;       // escrever Compare limpa pending
    else if (timer_hit)
      timer_pending <= 1'b1;
  end

  // Vetor de interrupções incluindo Timer no bit mais alto (IP7)
  wire [7:0] interrupts_with_timer = {timer_pending, interrupts[6:0]};

  // --- Unidade de exceções ---
  cp0_exception exception_unit (
    .syscall(syscall),
    .ri(ri),
    .iec(iec),
    .interrupts(interrupts_with_timer),
     .overflow(overflow),
     .divzero(divzero),
    .pendingexception(pendingexception),
    .exccode(exccode)
  );

  // --- EPC ---
  cp0_epc epc_unit (
    .clk(clk),
    .reset(reset),
    .activeexception(activeexception),
    .pc(pc),
    .epc(epc)
  );

  // --- STATUS ---
  cp0_status status_unit (
    .clk(clk),
    .reset(reset),
    .writeenable(cop0write && (cp0_writeaddress == 5'b01100)),
    .activeexception(activeexception),
    .eret(eret),
    .writedata(writecop0),
    .statusreg(statusreg),
    .iec(iec)
  );

  // --- CAUSE ---
  cp0_cause cause_unit (
    .clk(clk),
    .reset(reset),
    .activeexception(activeexception),
    .exccode(exccode),
    .interrupts(interrupts_with_timer),
    .causereg(causereg)
  );

  // --- COUNT ---
  cp0_count count_unit (
    .clk(clk),
    .reset(reset),
    .writeenable(cop0write && (cp0_writeaddress == 5'b01001)),
    .writedata(writecop0),
    .count(count)
  );

  // --- COMPARE ---
  cp0_compare compare_unit (
    .clk(clk),
    .reset(reset),
    .writeenable(cop0write && (cp0_writeaddress == 5'b01011)),
    .writedata(writecop0),
    .compare(compare)
  );

  // === IntCtl ===
  wire [31:0] intctl_value;
  cp0_intctl intctl_unit (
    .rdata(intctl_value)
  );

  // --- MFC0 (leitura) ---
  always @(cp0_readaddress or statusreg or causereg or epc or count or compare) begin
    case (cp0_readaddress)
    // faz sentido ler Status em 12.1 e IntCtl 12.1?? ****************@Rodrigo.pereira**************
      5'd12: begin
        if(cp0_sel == 3'b000)
          cop0readdata = statusreg;   // Status
        else if(cp0_sel == 3'b001)
          cop0readdata = intctl_value; // IntCtl
        else
          cop0readdata = 32'hXXXXXXXX;
      end
      //5'd12: cop0readdata = statusreg;   // Status
      //5'd20: cop0readdata = intctl_value; // IntCtl em numero livre **********@Rodrigo.pereira**************
      //caso nao tenha suporte ao campo sel.
      5'd13: cop0readdata = causereg;  // Cause
      5'd14: cop0readdata = epc;       // EPC
      5'd9 : cop0readdata = count;     // Count
      5'd11: cop0readdata = compare;   // Compare
      default: cop0readdata = 32'hXXXXXXXX;
    endcase
  end

endmodule
