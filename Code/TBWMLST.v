

module tb_wm;

// Internal signal declarations
reg start_button_tb, pause_button_tb, clk_tb, reset_tb;
wire out;

// Instantiate the DUT (Device Under Test)
top Dut (
    .start_button(start_button_tb),
    .pause_button(pause_button_tb),
    .reset(reset_tb),
    .clk(clk_tb),
    .out(out)
);

// Clock generation
initial begin
    clk_tb = 1'b0;
    forever #25 clk_tb = ~clk_tb; // 40ns clock period
end

// Test stimulus
initial begin
    // Initial reset
    reset_tb = 1'b1;
    start_button_tb = 0;
    pause_button_tb = 0;
    #50 reset_tb = 1'b0; // De-assert reset after 50ns

    // Directed stimulus: Basic washing cycle
    #50 start_button_tb = 1; // Start the washing cycle
    #1600 pause_button_tb = 1; // Pause during operation
    #300 pause_button_tb = 0; // Resume operation
    #5000 start_button_tb = 0; // End the washing cycle

    // Randomized stimulus for robustness testing
    repeat (5) begin
        start_button_tb = $random % 2;
        pause_button_tb = $random % 2;
        #($urandom_range(100, 500)); // Random delay between 100ns and 500ns
    end

    $stop; // End simulation
end

// Assertions to verify FSM behavior
always @(posedge clk_tb) begin
    if (reset_tb) begin
        // FSM should be in "Off" state after reset
        if (Dut.fsm_1.state != 3'b000) begin
            $fatal("FSM failed to reset to Off state.");
        end
    end else begin
        // FSM state transitions
        case (Dut.fsm_1.state)
            3'b000: begin
                if (Dut.fsm_1.next_state != 3'b001 && Dut.fsm_1.next_state != 3'b000) begin
                    $fatal("Invalid transition from Off state.");
                end
            end
            3'b001: begin
                if (Dut.fsm_1.next_state != 3'b010 && Dut.fsm_1.next_state != 3'b001) begin
                    $fatal("Invalid transition from FillWater state.");
                end
            end
            3'b010: begin
                if (Dut.fsm_1.next_state != 3'b011 && Dut.fsm_1.next_state != 3'b010) begin
                    $fatal("Invalid transition from Wash state.");
                end
            end
            3'b011: begin
                if (Dut.fsm_1.next_state != 3'b100 && Dut.fsm_1.next_state != 3'b011) begin
                    $fatal("Invalid transition from Drain state.");
                end
            end
            3'b100: begin
                if (Dut.fsm_1.next_state != 3'b101 && Dut.fsm_1.next_state != 3'b100) begin
                    $fatal("Invalid transition from Rinse state.");
                end
            end
            3'b101: begin
                if (Dut.fsm_1.next_state != 3'b110 && Dut.fsm_1.next_state != 3'b101) begin
                    $fatal("Invalid transition from Spin state.");
                end
            end
            3'b110: begin
                if (Dut.fsm_1.next_state != 3'b000) begin
                    $fatal("Invalid transition from Done state.");
                end
            end
            default: begin
                $fatal("Unknown FSM state encountered.");
            end
        endcase
    end
end

// Assertions for counter behavior
always @(posedge clk_tb) begin
    if (reset_tb) begin
        if (Dut.T_1.counter != 4'b0000) begin
            $fatal("Counter did not reset correctly.");
        end
    end else if (Dut.T_1.enable) begin
        if (Dut.T_1.counter > 4'b1111) begin
            $fatal("Counter exceeded maximum value.");
        end
    end
end

endmodule