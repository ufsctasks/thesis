// ---------------------------------------------------------------------------
// cp0_count_compare_tb.sv
//
// Testbench para o Coprocessador 0 do MIPS_S_Cp0.
//
// O testbench atua no lugar do MIPS_S: gera os estimulos que a CPU geraria
// (escritas e leituras de registradores de controle, sinalizacao de excecao
// e de retorno) e verifica as saidas produzidas pelo coprocessador.
//
// Foco desta versao: o par Count/Compare e o caminho de interrupcao do timer,
// conforme priorizado na orientacao de 29/09/2025.
//
// Execucao com Icarus Verilog:
//   iverilog -g2012 -o sim hw/*.v tb/cp0_count_compare_tb.sv && vvp sim
//
// Autor: Emir Braz de Araujo Marques Junior
// ---------------------------------------------------------------------------
`timescale 1ns / 1ps

module cp0_count_compare_tb;

  // -------------------------------------------------------------------------
  // Enderecos dos registradores de controle, no formato [7:3].[2:0]
  // -------------------------------------------------------------------------
  localparam [7:0] ADDR_COUNT   = 8'b01001_000;  //  9.0
  localparam [7:0] ADDR_COMPARE = 8'b01011_000;  // 11.0
  localparam [7:0] ADDR_STATUS  = 8'b01100_000;  // 12.0
  localparam [7:0] ADDR_INTCTL  = 8'b01100_001;  // 12.1
  localparam [7:0] ADDR_CAUSE   = 8'b01101_000;  // 13.0
  localparam [7:0] ADDR_EPC     = 8'b01110_000;  // 14.0

  localparam [31:0] INTCTL_EXPECTED = 32'h68000020;

  // -------------------------------------------------------------------------
  // Sinais de interface com o DUT
  // -------------------------------------------------------------------------
  logic        clk;
  logic        reset;
  logic        cp0_write_en;
  logic [7:0]  cp0_read_addr;
  logic [7:0]  cp0_write_addr;
  logic [31:0] cp0_write_data;
  logic [7:4]  interrupts;
  logic        syscall;
  logic        ri;
  logic        overflow;
  logic        eret;
  logic        activeexception;

  wire  [31:0] cop0readdata;
  wire         pendingexception;

  // -------------------------------------------------------------------------
  // Contadores de verificacao
  // -------------------------------------------------------------------------
  int checks_run  = 0;
  int checks_fail = 0;

  // -------------------------------------------------------------------------
  // Instancia do dispositivo sob teste
  // -------------------------------------------------------------------------
  coprocessor0 dut (
    .clk              (clk),
    .reset            (reset),
    .cp0_write_en     (cp0_write_en),
    .cp0_read_addr    (cp0_read_addr),
    .cp0_write_addr   (cp0_write_addr),
    .cp0_write_data   (cp0_write_data),
    .interrupts       (interrupts),
    .syscall          (syscall),
    .ri               (ri),
    .overflow         (overflow),
    .eret             (eret),
    .activeexception  (activeexception),
    .cop0readdata     (cop0readdata),
    .pendingexception (pendingexception)
  );

  // -------------------------------------------------------------------------
  // Geracao de clock: periodo de 10 ns
  // -------------------------------------------------------------------------
  initial clk = 1'b0;
  always #5 clk = ~clk;

  // -------------------------------------------------------------------------
  // Tarefas auxiliares
  // -------------------------------------------------------------------------

  // Emula a execucao de uma instrucao MTC0
  task automatic mtc0(input [7:0] addr, input [31:0] data);
    begin
      @(negedge clk);
      cp0_write_addr = addr;
      cp0_write_data = data;
      cp0_write_en   = 1'b1;
      @(negedge clk);
      cp0_write_en   = 1'b0;
    end
  endtask

  // Emula a execucao de uma instrucao MFC0. A leitura e combinacional.
  task automatic mfc0(input [7:0] addr, output [31:0] data);
    begin
      cp0_read_addr = addr;
      #1;
      data = cop0readdata;
    end
  endtask

  // Emula a efetivacao de uma excecao pela CPU
  task automatic take_exception();
    begin
      @(negedge clk);
      activeexception = 1'b1;
      @(negedge clk);
      activeexception = 1'b0;
    end
  endtask

  // Emula a execucao de uma instrucao ERET
  task automatic do_eret();
    begin
      @(negedge clk);
      eret = 1'b1;
      @(negedge clk);
      eret = 1'b0;
    end
  endtask

  // Verificacao de igualdade com registro de resultado
  task automatic check_eq(input string name,
                          input [31:0] got,
                          input [31:0] expected);
    begin
      checks_run++;
      if (got === expected) begin
        $display("  [PASS] %-46s = 0x%08h", name, got);
      end
      else begin
        checks_fail++;
        $display("  [FAIL] %-46s = 0x%08h (esperado 0x%08h)",
                 name, got, expected);
      end
    end
  endtask

  task automatic check_bit(input string name,
                           input logic got,
                           input logic expected);
    begin
      checks_run++;
      if (got === expected) begin
        $display("  [PASS] %-46s = %0b", name, got);
      end
      else begin
        checks_fail++;
        $display("  [FAIL] %-46s = %0b (esperado %0b)", name, got, expected);
      end
    end
  endtask

  // -------------------------------------------------------------------------
  // Sequencia de teste
  // -------------------------------------------------------------------------
  logic [31:0] rd;
  logic [31:0] count_snapshot;

  initial begin
    $dumpfile("cp0_count_compare_tb.vcd");
    $dumpvars(0, cp0_count_compare_tb);

    // --- estado inicial dos estimulos ---
    reset           = 1'b1;
    cp0_write_en    = 1'b0;
    cp0_read_addr   = ADDR_STATUS;
    cp0_write_addr  = 8'b0;
    cp0_write_data  = 32'b0;
    interrupts      = 4'b0000;
    syscall         = 1'b0;
    ri              = 1'b0;
    overflow        = 1'b0;
    eret            = 1'b0;
    activeexception = 1'b0;

    $display("\n==============================================================");
    $display(" Testbench do Coprocessador 0 - par Count/Compare");
    $display("==============================================================");

    // -----------------------------------------------------------------------
    $display("\n[1] Reset e valores iniciais");
    // -----------------------------------------------------------------------
    repeat (3) @(negedge clk);
    reset = 1'b0;
    @(negedge clk);

    mfc0(ADDR_INTCTL, rd);
    check_eq("IntCtl e constante de leitura", rd, INTCTL_EXPECTED);

    mfc0(ADDR_STATUS, rd);
    check_bit("Status.IE desabilitado apos reset", rd[0], 1'b0);
    check_bit("Status.EXL limpo apos reset",       rd[1], 1'b0);

    // Observacao, nao verificacao: ao sair do reset Count e Compare valem
    // zero, de modo que a comparacao e verdadeira e o timer pode marcar
    // pendencia sem ter sido programado. Como Cause e registrado, a leitura
    // precisa ocorrer alguns ciclos apos o reset para refletir o estado ja
    // assentado. A decisao sobre como tratar isso esta em aberto com a
    // orientacao; ver docs/register_map.md.
    repeat (3) @(negedge clk);
    mfc0(ADDR_CAUSE, rd);
    $display("  [INFO] Cause.IP[3] tres ciclos apos o reset      = %0b  %s",
             rd[11],
             rd[11] ? "<-- disparo espurio do timer" : "(sem disparo espurio)");

    // -----------------------------------------------------------------------
    $display("\n[2] Count incrementa livremente");
    // -----------------------------------------------------------------------
    mfc0(ADDR_COUNT, count_snapshot);
    repeat (10) @(negedge clk);
    mfc0(ADDR_COUNT, rd);
    check_eq("Count avancou 10 ciclos", rd - count_snapshot, 32'd10);

    // -----------------------------------------------------------------------
    $display("\n[3] Escrita e leitura de Count e Compare (MTC0/MFC0)");
    // -----------------------------------------------------------------------
    mtc0(ADDR_COUNT, 32'h0000_1000);
    mfc0(ADDR_COUNT, rd);
    // Count continua incrementando apos a escrita, logo verifica-se a faixa
    check_bit("Count carregado por MTC0", (rd >= 32'h0000_1000) &&
                                          (rd <  32'h0000_1010), 1'b1);

    mtc0(ADDR_COMPARE, 32'h0000_2000);
    mfc0(ADDR_COMPARE, rd);
    check_eq("Compare carregado por MTC0", rd, 32'h0000_2000);

    // -----------------------------------------------------------------------
    $display("\n[4] Disparo da interrupcao do timer");
    // -----------------------------------------------------------------------
    // Habilita interrupcoes globalmente (Status.IE = 1)
    mtc0(ADDR_STATUS, 32'h0000_0001);
    mfc0(ADDR_STATUS, rd);
    check_bit("Status.IE habilitado por MTC0", rd[0], 1'b1);

    // Programa o Compare para disparar em 20 ciclos
    mfc0(ADDR_COUNT, count_snapshot);
    mtc0(ADDR_COMPARE, count_snapshot + 32'd20);

    check_bit("pendingexception inativo antes do disparo",
              pendingexception, 1'b0);

    // Aguarda o disparo
    repeat (40) @(negedge clk);

    check_bit("pendingexception ativo apos Count == Compare",
              pendingexception, 1'b1);

    mfc0(ADDR_CAUSE, rd);
    check_bit("Cause.IP[3] indica timer pendente", rd[11], 1'b1);
    check_bit("Cause.TI indica timer pendente",    rd[30], 1'b1);

    // -----------------------------------------------------------------------
    $display("\n[5] Efetivacao da excecao e atualizacao do Status");
    // -----------------------------------------------------------------------
    take_exception();

    mfc0(ADDR_STATUS, rd);
    check_bit("Status.EXL setado ao tomar excecao", rd[1], 1'b1);
    check_bit("Status.IE limpo ao tomar excecao",   rd[0], 1'b0);

    mfc0(ADDR_CAUSE, rd);
    check_eq("Cause.ExcCode indica interrupcao (0)", rd[6:2], 5'd0);

    // -----------------------------------------------------------------------
    $display("\n[6] Escrita em Compare reconhece a interrupcao");
    // -----------------------------------------------------------------------
    mfc0(ADDR_COUNT, count_snapshot);
    mtc0(ADDR_COMPARE, count_snapshot + 32'd1000);
    @(negedge clk);

    mfc0(ADDR_CAUSE, rd);
    check_bit("Cause.IP[3] limpo apos escrever Compare", rd[11], 1'b0);
    check_bit("Cause.TI limpo apos escrever Compare",    rd[30], 1'b0);

    // -----------------------------------------------------------------------
    $display("\n[7] Retorno de excecao (ERET)");
    // -----------------------------------------------------------------------
    do_eret();

    mfc0(ADDR_STATUS, rd);
    check_bit("Status.EXL limpo apos ERET", rd[1], 1'b0);
    check_bit("Status.IE restaurado apos ERET", rd[0], 1'b1);

    // -----------------------------------------------------------------------
    $display("\n[8] Interrupcao externa nos pinos IP[7:4]");
    // -----------------------------------------------------------------------
    interrupts = 4'b0010;   // ativa IP[5]
    #1;
    // pendingexception e combinacional: responde imediatamente
    check_bit("pendingexception ativo com IRQ externa",
              pendingexception, 1'b1);

    // Cause e registrado: exige uma borda de clock para capturar o novo IP
    @(negedge clk);
    mfc0(ADDR_CAUSE, rd);
    check_bit("Cause.IP[5] reflete o pino externo", rd[13], 1'b1);

    interrupts = 4'b0000;
    #1;
    check_bit("pendingexception inativo sem IRQ",
              pendingexception, 1'b0);

    // -----------------------------------------------------------------------
    $display("\n[9] Mascaramento por Status.IE");
    // -----------------------------------------------------------------------
    mtc0(ADDR_STATUS, 32'h0000_0000);   // desabilita IE
    interrupts = 4'b0100;
    #1;
    check_bit("IRQ externa mascarada com IE = 0",
              pendingexception, 1'b0);
    interrupts = 4'b0000;

    // -----------------------------------------------------------------------
    // Resumo
    // -----------------------------------------------------------------------
    $display("\n==============================================================");
    if (checks_fail == 0)
      $display(" RESULTADO: %0d verificacoes, todas aprovadas.", checks_run);
    else
      $display(" RESULTADO: %0d verificacoes, %0d FALHARAM.",
               checks_run, checks_fail);
    $display("==============================================================\n");

    $finish;
  end

  // -------------------------------------------------------------------------
  // Guarda de tempo, evita simulacao infinita
  // -------------------------------------------------------------------------
  initial begin
    #100000;
    $display("\n[ERRO] Timeout da simulacao.");
    $finish;
  end

endmodule
