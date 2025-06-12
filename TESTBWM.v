module tb_wm();

// Internal signal declaration
reg start_button_tb, pause_button_tb, clk_tb, reset_tb;
wire out;

top Dut(
  .start_button(start_button_tb),
  .pause_button(pause_button_tb),
  .reset(reset_tb),
  .clk(clk_tb),
  .out(out)
);

// Testing block
initial begin
  start_button_tb = 0;
  pause_button_tb = 0;
  reset_tb = 1'b1;
  #10 reset_tb = 1'b0;
  #40

  // Start washing process and check FSM transitions
  start_button_tb = 1;
  #1600
  assert(out == 0) else $fatal("Output should be 0 before 'Done' state");
  
  // Pause and resume
  pause_button_tb = 1;
  #300
  pause_button_tb = 0;
  #6000

  // Check final state and output
  assert(out == 1) else $fatal("Output should be 1 in 'Done' state");
  
  $stop;
end

// Clock generation
initial begin
  clk_tb = 1'b0;
  forever #25 clk_tb = ~clk_tb;
end
endmodule
