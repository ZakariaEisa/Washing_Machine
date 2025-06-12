module top(
  input start_button, pause_button,
  input clk, reset,
  output out
);

wire [3:0] count;

WashingMachineFSM fsm_1(
  .reset(reset),
  .clk(clk),
  .start(start_button),
  .timer(count),
  .o(out)
);

timer T_1(
  .reset(reset),
  .clk(clk),
  .enable(start_button & (~pause_button)),
  .counter(count)
);

endmodule
