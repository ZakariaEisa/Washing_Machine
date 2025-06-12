module timer (
  input enable,
  input reset,
  input clk,
  output reg [3:0] counter
);

always @(posedge clk) begin
  if (reset)
    counter <= 4'b0;
  else if (enable && (counter != 4'b1111))
    counter <= counter + 1;
  else
    counter <= 4'b0;
end

// Assertion to check if the timer increments correctly
assert property (@(posedge clk) 
  (reset == 1'b1 && counter == 4'b0) || 
  (enable && counter < 4'b1111 && counter == counter + 1) ||
  (~enable && counter == counter)
) else $fatal("Timer counter is incorrect! Counter value: %d", counter);
endmodule
