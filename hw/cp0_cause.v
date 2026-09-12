// cp0_cause.v
// CAUSE Register (CP0 Reg 13, sel=0)
// Campos implementados: ExcCode[6:2], IP[15:8], TI (bit 30)
//
// O vetor de interrupcoes pendentes chega ja montado pelo modulo de topo,
// onde IP[7:4] sao os pinos externos, IP[3] e o timer interno (Count/Compare)
// e IP[2:0] sao reservados e permanecem em zero.
module cp0_cause (
  input        clk,
  input        reset,
  input        activeexception,   // sinal do controle
  input  [4:0] exccode,           // codigo da excecao
  input  [7:0] ip_pending,        // IP[7:0] ja montado pelo modulo de topo
  input        timer_pending,     // usado apenas para refletir o bit TI
  output reg [31:0] cause
);

  always @(posedge clk) begin
    if (reset) begin
      cause <= 32'b0;
    end
    else begin
      // IP[15:8] reflete continuamente os pedidos pendentes
      cause[15:8] <= ip_pending;

      // TI (bit 30) reflete especificamente o pendente do timer
      cause[30]   <= timer_pending;

      // ExcCode e atualizado somente quando uma excecao e efetivada
      if (activeexception) begin
        cause[6:2] <= exccode;
        cause[1:0] <= 2'b00;   // bits reservados
      end
    end
  end

endmodule
