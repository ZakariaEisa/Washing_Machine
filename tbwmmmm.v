module tb_wm;

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

// Clock generation
initial begin
  clk_tb = 1'b0;
  forever #25 clk_tb = ~clk_tb; // 40 MHz clock
end

// Randomized Test sequence
initial begin
  // Initialize inputs
  start_button_tb = 0;
  pause_button_tb = 0;
  reset_tb = 1'b1;
  #10
  reset_tb = 1'b0;
  #40

  // Simulate pressing the start button with random delay
  random_start_button();

  // Simulate the filling, washing, draining, and rinsing phases with random delays
  random_delay();
  random_pause_button(); // Simulate a random pause
  random_unpause(); // Simulate a random unpause

  random_delay();
  random_pause_button(); // Another pause during the cycle
  random_unpause(); // Unpause again

  // End the cycle after random delays
  random_end_of_cycle();

  // Finish simulation after some time
  #5000;
  $stop;
end

// Random start button press function
task random_start_button;
  begin
    #($random % 100); // Random delay before pressing start
    start_button_tb = 1; // Press start button
    #10 start_button_tb = 0; // Release start button
  end
endtask

// Random pause button press function
task random_pause_button;
  begin
    #($random % 200 + 100); // Random delay before pressing pause
    pause_button_tb = 1; // Press pause button
    #10 pause_button_tb = 0; // Release pause button
  end
endtask

// Random unpause button press function
task random_unpause;
  begin
    #($random % 200 + 100); // Random delay before unpausing
    pause_button_tb = 1; // Unpress pause button (unpause)
    #10 pause_button_tb = 0; // Release pause button
  end
endtask

// Random delay between washing phases (FillWater, Wash, Drain, etc.)
task random_delay;
  begin
    #($random % 100 + 50); // Random delay between 50 ns to 150 ns for different phases
  end
endtask

// Random end of cycle behavior
task random_end_of_cycle;
  begin
    #($random % 300 + 200); // Random delay at the end of the cycle, up to 500ns
  end
endtask

endmodule

