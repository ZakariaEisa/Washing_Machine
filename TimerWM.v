
module timer (
  input wire enable,
  input wire reset,
  input wire clk,
  output reg [3:0] counter
);

  reg [3:0] counter_coverage; // Coverage for the counter values

  // Timer functionality
  always @(posedge clk) begin
    if (reset)
      counter <= 4'b0000;
    else if (enable && (counter != 4'b1111))
      counter <= counter + 1;
    else
      counter <= 4'b0000;
  end

  // Manually track coverage for counter values
  always @(posedge clk) begin
    if (counter == 4'b0000)
      counter_coverage[0] = 1;  // Coverage for zero counter value
    if (counter == 4'b1111)
      counter_coverage[1] = 1;  // Coverage for maximum counter value
  end

  // Assertions for the counter module
  always @(posedge clk) begin
    // Assertion: Ensure that counter resets to 0 on reset
    if (reset && counter != 4'b0000) begin
      $display("Assertion Failed: Counter did not reset to 0!");
      $fatal;
    end

    // Assertion: Ensure that counter increments when enabled
    if (enable && counter != counter + 1 && counter != 4'b1111) begin
      $display("Assertion Failed: Counter did not increment as expected!");
      $fatal;
    end
  end

endmodule
