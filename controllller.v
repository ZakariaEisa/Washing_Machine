module WashingMachineFSM(
  input wire start,
  input reset, clk,
  input wire [3:0] timer,
  output reg o
);

// State encoding
parameter Off = 3'b000, FillWater = 3'b001, Wash = 3'b010,
          Drain = 3'b011, Rinse = 3'b100, Spin = 3'b101, Done = 3'b110;

// State and next state variables
reg [2:0] state, next_state;

always @(posedge clk or posedge reset) begin
  if (reset)
    state <= Off;
  else
    state <= next_state;
end

always @(*) begin
  case (state)
    Off: begin
      if (start)
        next_state = FillWater;
      else
        next_state = Off;
    end
    FillWater: begin
      if (timer == 4'b1111)
        next_state = Wash;
      else
        next_state = FillWater;
    end
    Wash: begin
      if (timer == 4'b1111)
        next_state = Drain;
      else
        next_state = Wash;
    end
    Drain: begin
      if (timer == 4'b1111)
        next_state = Rinse;
      else
        next_state = Drain;
    end
    Rinse: begin
      if (timer == 4'b1111)
        next_state = Spin;
      else
        next_state = Rinse;
    end
    Spin: begin
      if (timer == 4'b1111)
        next_state = Done;
      else
        next_state = Spin;
    end
    Done: begin
      next_state = Off;
    end
    default: begin
      next_state = Off;
    end
  endcase

  case (state)
    Off: o = 0;
    FillWater: o = 0;
    Wash: o = 0;
    Drain: o = 0;
    Rinse: o = 0;
    Spin: o = 0;
    Done: o = 1;
  endcase
end
endmodule

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

endmodule

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

