
module top(
  input wire start_button,
  input wire pause_button,
  input wire clk,
  input wire reset,
  output wire out
);

  wire [3:0] count;
  wire [2:0] fsm_state;  // Added wire for FSM state

  // FSM Instance
  WashingMachineFSM fsm_1(
    .reset(reset),
    .clk(clk),
    .start(start_button),
    .timer(count),
    .o(out),
    .state(fsm_state)  // Connect the state output from FSM
  );

  // Timer Instance
  timer T_1(
    .reset(reset),
    .clk(clk),
    .enable(start_button & (~pause_button)),
    .counter(count)
  );

  reg out_coverage; // Coverage for the output state

  // Assertion for the output signal (checking if FSM is in 'Done' state)
  always @(posedge clk) begin
    if (fsm_state == 3'b110 && out != 1) begin  // 3'b110 is 'Done' state
      $display("Assertion Failed: Output should be 1 when state is Done!");
      $fatal;
    end
  end

  // Track output coverage when state is Done
  always @(posedge clk) begin
    if (fsm_state == 3'b110)  // 3'b110 is 'Done' state
      out_coverage = 1;  // Mark coverage for 'Done' state
  end

endmodule
