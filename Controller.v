module WashingMachineFSM(
  input wire start,
  input wire reset, clk,
  input wire [3:0] timer,
  input wire [1:0] cycle_select, // 00: Quick Wash, 01: Normal, 10: Heavy, 11: Delicate
  input wire [1:0] water_level_select, // 00: Low, 01: Medium, 10: High
  input wire [1:0] temp_select, // 00: Cold, 01: Warm, 10: Hot
  input wire lid_closed, water_full, load_balanced,
  output reg motor_on, water_pump_on, alarm, door_locked,
  output reg cycle_led, // LED for cycle status
  output reg [7:0] timer_output, // 8-bit timer
  output reg end_of_cycle_alarm
);

// State encoding
parameter Off = 3'b000, Idle = 3'b001, FillWater = 3'b010, 
          Wash = 3'b011, Rinse = 3'b100, Spin = 3'b101, Done = 3'b110, Error = 3'b111;

// State and next state variables
reg [2:0] state, next_state;

// Timer for cycle countdown
always @(posedge clk or posedge reset) begin
  if (reset) 
    timer_output <= 8'd0;
  else if (timer_output > 0)
    timer_output <= timer_output - 1;
end

// State transition logic
always @(posedge clk or posedge reset) begin
  if (reset) 
    state <= Off;
  else
    state <= next_state;
end

// Output logic and state transitions
always @(*) begin
  // Default output values
  motor_on = 0;
  water_pump_on = 0;
  alarm = 0;
  door_locked = 0;
  cycle_led = 0;
  end_of_cycle_alarm = 0;
  next_state = state; // Default to hold state

  case (state)
    Off: begin
      cycle_led = 0;
      if (start) 
        next_state = Idle;
    end

    Idle: begin
      cycle_led = 1;
      if (start) begin
        if (lid_closed && load_balanced) begin
          door_locked = 1;
          next_state = FillWater;
        end else begin
          alarm = 1; // Error due to lid not closed or unbalanced load
          next_state = Error;
        end
      end
    end

    FillWater: begin
      water_pump_on = 1;
      if (water_full) 
        next_state = Wash;
    end

    Wash: begin
      motor_on = 1;
      case (cycle_select)
        2'b00: timer_output = 8'd5;  // Quick Wash
        2'b01: timer_output = 8'd10; // Normal
        2'b10: timer_output = 8'd15; // Heavy
        2'b11: timer_output = 8'd8;  // Delicate
      endcase
      if (timer_output == 0) next_state = Rinse;
    end

    Rinse: begin
      motor_on = 1;
      next_state = Spin;
    end

    Spin: begin
      motor_on = 1;
      case (water_level_select)
        2'b00: timer_output = 8'd3;  // Low water level
        2'b01: timer_output = 8'd5;  // Medium
        2'b10: timer_output = 8'd7;  // High
      endcase
      if (timer_output == 0) next_state = Done;
    end

    Done: begin
      door_locked = 0;
      end_of_cycle_alarm = 1;  // End of cycle alarm
      next_state = Off;
    end

    Error: begin
      alarm = 1;  // Signal error
      next_state = Off;
    end

    default: next_state = Off;
  endcase
end

endmodule
