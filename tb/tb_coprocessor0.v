`timescale 1ns / 1ps
// ============================================================================
// Testbench do coprocessor0 (CP0) - teste unitario, sem o MIPS
// Endereco CP0 = {reg[4:0], sel[2:0]}  ->  ex.: Status (12,0) = 8'b01100_000
// ============================================================================
module tb_coprocessor0;

  // --- enderecos dos registradores ---
  localparam [7:0] A_COUNT   = 8'b01001_000; // 9.0
  localparam [7:0] A_COMPARE = 8'b01011_000; // 11.0
  localparam [7:0] A_STATUS  = 8'b01100_000; // 12.0
  localparam [7:0] A_INTCTL  = 8'b01100_001; // 12.1
  localparam [7:0] A_CAUSE   = 8'b01101_000; // 13.0
  localparam [7:0] A_EPC     = 8'b01110_000; // 14.0

  // --- ExcCodes MIPS32 ---
  localparam [4:0] EXC_INT = 5'd0;
  localparam [4:0] EXC_SYS = 5'd8;
  localparam [4:0] EXC_RI  = 5'd10;
  localparam [4:0] EXC_OV  = 5'd12;

  // --- sinais do DUT ---
  reg         clk = 0, reset = 1;
  reg         cp0_write_en = 0;
  reg  [7:0]  cp0_read_addr = 0, cp0_write_addr = 0;
  reg  [31:0] cp0_write_data = 0;
  reg  [31:0] pc = 0;
  reg  [7:4]  interrupts = 0;
  reg         syscall = 0, ri = 0, overflow = 0, eret = 0;
  reg         activeexception = 0;
  wire [31:0] cop0readdata;
  wire        pendingexception;

  integer errors = 0;
  integer i;
  reg [31:0] v, v2;

  coprocessor0 dut (
    .clk(clk), .reset(reset),
    .cp0_write_en(cp0_write_en),
    .cp0_read_addr(cp0_read_addr),
    .cp0_write_addr(cp0_write_addr),
    .cp0_write_data(cp0_write_data),
    .pc(pc),
    .interrupts(interrupts),
    .syscall(syscall), .ri(ri), .overflow(overflow), .eret(eret),
    .activeexception(activeexception),
    .cop0readdata(cop0readdata),
    .pendingexception(pendingexception)
  );

  always #5 clk = ~clk; // 100 MHz

  // ------------------------------------------------------------------ tasks
  // Estimulos sempre aplicados na borda de descida (evita corrida com posedge)

  task mtc0(input [7:0] addr, input [31:0] data);
    begin
      @(negedge clk);
      cp0_write_addr = addr; cp0_write_data = data; cp0_write_en = 1;
      @(negedge clk);
      cp0_write_en = 0;
    end
  endtask

  task mfc0(input [7:0] addr, output [31:0] data);
    begin
      @(negedge clk);
      cp0_read_addr = addr;
      #1 data = cop0readdata;
    end
  endtask

  task check(input [8*48-1:0] name, input [31:0] got, input [31:0] exp);
    begin
      if (got === exp)
        $display("[ OK ] %0s = 0x%08h", name, got);
      else begin
        $display("[FAIL] %0s = 0x%08h (esperado 0x%08h)", name, got, exp);
        errors = errors + 1;
      end
    end
  endtask

  task show(input [8*48-1:0] name, input [7:0] addr);
    reg [31:0] d;
    begin
      mfc0(addr, d);
      $display("       %0s = 0x%08h", name, d);
    end
  endtask

  // CPU "aceita" a excecao: pulso de 1 ciclo em activeexception
  task accept_exception;
    begin
      @(negedge clk); activeexception = 1;
      @(negedge clk); activeexception = 0;
    end
  endtask

  task do_eret;
    begin
      @(negedge clk); eret = 1;
      @(negedge clk); eret = 0;
    end
  endtask

  // Testa uma excecao sincrona na instrucao de endereco 'addr':
  // liga o sinal, confere pending, aceita, confere ExcCode e EPC,
  // simula o handler fazendo EPC+4 e retorna com ERET
  task sync_exception(input [8*48-1:0] name, input integer which,
                      input [4:0] exp_code, input [31:0] addr);
    begin
      $display("\n--- %0s (PC = 0x%08h) ---", name, addr);
      @(negedge clk);
      pc = addr;
      case (which)
        0: syscall  = 1;
        1: ri       = 1;
        2: overflow = 1;
      endcase
      #1 check("pendingexception", pendingexception, 1);
      activeexception = 1;   // sinal da excecao fica ativo no ciclo do activeexception
      @(negedge clk); activeexception = 0; syscall = 0; ri = 0; overflow = 0;
      mfc0(A_CAUSE, v);
      check("Cause.ExcCode", v[6:2], exp_code);
      mfc0(A_STATUS, v);
      check("Status.EXL", v[1], 1);
      mfc0(A_EPC, v);
      check("EPC = PC da instrucao", v, addr);
      mtc0(A_EPC, v + 4);    // handler: EPC <- EPC + 4
      mfc0(A_EPC, v);
      check("EPC apos MTC0 (EPC+4)", v, addr + 4);
      do_eret;
      mfc0(A_STATUS, v);
      check("Status.EXL apos ERET", v[1], 0);
    end
  endtask

  // ------------------------------------------------------------------ teste
  initial begin
    $display("=== TB coprocessor0 ===");
    repeat (3) @(negedge clk);
    reset = 0;

    // 1) Valores apos reset
    $display("\n--- Apos reset ---");
    show("Status", A_STATUS);
    show("Cause ", A_CAUSE);
    show("EPC   ", A_EPC);
    show("IntCtl", A_INTCTL);

    // 2) Compare: escrita e leitura (tambem limpa o timer_pending)
    $display("\n--- Compare ---");
    mtc0(A_COMPARE, 32'd1000);
    mfc0(A_COMPARE, v);
    check("Compare", v, 32'd1000);

    // 3) Count: escrita e incremento
    $display("\n--- Count ---");
    mtc0(A_COUNT, 32'd0);
    mfc0(A_COUNT, v);
    repeat (10) @(negedge clk);
    mfc0(A_COUNT, v2);
    $display("       Count: %0d -> %0d (10 ciclos depois)", v, v2);
    if (v2 > v) $display("[ OK ] Count incrementa");
    else begin $display("[FAIL] Count nao incrementou"); errors = errors + 1; end

    // 4) Excecoes sincronas (independem de IE)
    sync_exception("SYSCALL",  0, EXC_SYS, 32'h0000_0040);
    sync_exception("RI",       1, EXC_RI,  32'h0000_0100);
    sync_exception("OVERFLOW", 2, EXC_OV,  32'h0000_0204);

    // 4b) Excecao dentro do handler (EXL=1) nao sobrescreve o EPC
    $display("\n--- EPC protegido por EXL ---");
    @(negedge clk); pc = 32'h0000_0300; syscall = 1; activeexception = 1;
    @(negedge clk); syscall = 0; activeexception = 0;
    @(negedge clk); pc = 32'h0000_4188; overflow = 1; activeexception = 1;
    @(negedge clk); overflow = 0; activeexception = 0;
    mfc0(A_EPC, v);
    check("EPC preservado com EXL=1", v, 32'h0000_0300);
    do_eret;

    // 5) Interrupcao do timer
    $display("\n--- Timer (Count == Compare) ---");
    mtc0(A_STATUS, 32'h0000_FF01);   // IM[7:0]=1, IE=1
    show("Status", A_STATUS);
    mtc0(A_COUNT,   32'd0);
    mtc0(A_COMPARE, 32'd20);
    i = 0;
    while (!pendingexception && i < 500) begin @(negedge clk); i = i + 1; end
    if (pendingexception) $display("[ OK ] pendingexception subiu apos %0d ciclos", i);
    else begin $display("[FAIL] timer nao gerou interrupcao"); errors = errors + 1; end
    mfc0(A_CAUSE, v);
    check("Cause.IP[3] (timer)", v[11], 1);
    pc = 32'h0000_0500;              // instrucao interrompida
    accept_exception;
    mfc0(A_CAUSE, v);
    check("Cause.ExcCode", v[6:2], EXC_INT);
    mfc0(A_EPC, v);
    check("EPC = PC interrompido", v, 32'h0000_0500);
    show("Status", A_STATUS);
    mtc0(A_COMPARE, 32'd5000);       // escrever Compare limpa o pending
    mfc0(A_CAUSE, v);
    check("Cause.IP[3] apos escrever Compare", v[11], 0);
    do_eret;

    // 6) Interrupcao externa (pino 4)
    $display("\n--- Interrupcao externa IP[4] ---");
    mtc0(A_STATUS, 32'h0000_FF01);
    @(negedge clk); interrupts = 4'b0001;
    #1 check("pendingexception", pendingexception, 1);
    mfc0(A_CAUSE, v);
    check("Cause.IP[4]", v[12], 1);
    accept_exception;
    interrupts = 4'b0000;
    mfc0(A_CAUSE, v);
    check("Cause.ExcCode", v[6:2], EXC_INT);
    do_eret;

    // 7) Interrupcao com IE=0 nao deve gerar excecao
    $display("\n--- Interrupcao mascarada (IE=0) ---");
    mtc0(A_STATUS, 32'h0000_FF00);
    @(negedge clk); interrupts = 4'b0001;
    #1 check("pendingexception (IE=0)", pendingexception, 0);
    @(negedge clk); interrupts = 4'b0000;

    // Resumo
    $display("\n=== FIM: %0d erro(s) ===", errors);
    $finish;
  end

endmodule
