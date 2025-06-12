mo
module washing_machine_controller_v2(
    input clk,
    input reset,
    input power_button,
    input start_button,
    input [1:0] cycle_select, // 00: Quick Wash, 01: Normal, 10: Heavy, 11: Delicate
    input [1:0] water_level_select, // 00: Low, 01: Medium, 10: High
    input [1:0] temp_select, // 00: Cold, 01: Warm, 10: Hot
    input [1:0] spin_speed_select, // 00: Low, 01: Medium, 10: High
    input lid_closed,
    input water_full,
    input load_balanced,
    input load_detected, // Check if load is sufficient
    input self_cleaning_mode, // Trigger self-cleaning mode
    output reg motor_on,
    output reg water_pump_on,
    output reg alarm,
    output reg door_locked,
    output reg power_led,
    output reg cycle_led, // LED or display for cycle
    output reg [7:0] timer, // 8-bit timer for cycle countdown
    output reg end_of_cycle_alarm,
    output reg self_cleaning_led // LED for self-cleaning mode
);
    // State declarations
    reg [3:0] current_state, next_state;

    // State encoding
    parameter POWER_OFF = 4'b0000;
    parameter IDLE = 4'b0001;
    parameter FILLING = 4'b0010;
    parameter WASHING = 4'b0011;
    parameter RINSING = 4'b0100;
    parameter SPINNING = 4'b0101;
    parameter END_CYCLE = 4'b0110;
    parameter SELF_CLEANING = 4'b0111;
    parameter ERROR = 4'b1000;

    // Sequential logic: State transition
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= POWER_OFF;
            timer <= 8'd0;
        end else begin
            current_state <= next_state;
            // Countdown timer logic
            if (timer > 0) timer <= timer - 1;
        end
    end

    // Combinational logic: Next state and outputs
    always @(*) begin
        // Default output values
        motor_on = 0;
        water_pump_on = 0;
        alarm = 0;
        door_locked = 0;
        power_led = 0;
        cycle_led = 0;
        self_cleaning_led = 0;
        end_of_cycle_alarm = 0;
        next_state = current_state; // Default to hold state

        case (current_state)
            POWER_OFF: begin
                power_led = 0;
                if (power_button) begin
                    next_state = IDLE;
                end
            end
            
            IDLE: begin
                power_led = 1;
                if (start_button) begin
                    if (lid_closed && load_balanced && load_detected) begin
                        door_locked = 1;
                        next_state = FILLING;
                    end else begin
                        alarm = 1; // Lid not closed or unbalanced load
                        next_state = ERROR;
                    end
                end
            end
            
            FILLING: begin
                water_pump_on = 1;
                if (water_full) begin
                    next_state = WASHING; // Move to washing when water is full
                end
            end
            
            WASHING: begin
                motor_on = 1;
                case (cycle_select)
                    2'b00: timer = 8'd5; // Quick wash
                    2'b01: timer = 8'd10; // Normal
                    2'b10: timer = 8'd15; // Heavy
                    2'b11: timer = 8'd8; // Delicate
                endcase
                if (timer == 0) next_state = RINSING; // Move to rinsing when timer expires
            end
            
            RINSING: begin
                motor_on = 1;
                next_state = SPINNING; // Move to spinning after rinsing
            end
            
            SPINNING: begin
                motor_on = 1;
                case (spin_speed_select)
                    2'b00: timer = 8'd3; // Low
                    2'b01: timer = 8'd5; // Medium
                    2'b10: timer = 8'd7; // High
                endcase
                if (timer == 0) next_state = END_CYCLE; // Move to end cycle when timer expires
            end

            END_CYCLE: begin
                door_locked = 0;
                end_of_cycle_alarm = 1; // Signal cycle completion
                next_state = IDLE; // Return to idle after end cycle
            end
            
            SELF_CLEANING: begin
                self_cleaning_led = 1; // Activate self-cleaning LED
                // Self cleaning process, can be a fixed duration for cleaning
                timer = 8'd10; // Set a fixed cleaning time
                if (timer == 0) next_state = IDLE; // After cleaning, go back to idle
            end

            ERROR: begin
                alarm = 1; // Signal error
                next_state = POWER_OFF; // Return to power off state
            end
            
            default: next_state = POWER_OFF; // Default case to handle undefined states
        endcase
    end
endmodule