
`timescale 1ns/1ps

module RON_tb;

    // Inputs
    reg clk;
    reg rst;
    reg [2:0] ctrl;
    reg [7:0] data_in;

    // Outputs
    wire [7:0] data_out;
    wire [7:0] status;

    // DUT Instantiation
    RON dut (
        .clk(clk), .rst(rst), .ctrl(ctrl), .data_in(data_in),
        .data_out(data_out), .status(status)
    );

    // Clock Generation
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    

    // Input Initialization
    
    initial begin
        clk = 0;
        rst = 0;
        ctrl = 0;
        data_in = 0;
        #10; // Initial delay
    end
    

    // Test Stimuli
    
    initial begin
        
        // Random Test Case 1
        #10;
        clk = $random;
        rst = $random;
        ctrl = $random % 7;
        data_in = $random % 255;
        
        // Random Test Case 2
        #10;
        clk = $random;
        rst = $random;
        ctrl = $random % 7;
        data_in = $random % 255;
        
        // Random Test Case 3
        #10;
        clk = $random;
        rst = $random;
        ctrl = $random % 7;
        data_in = $random % 255;
        
        // Random Test Case 4
        #10;
        clk = $random;
        rst = $random;
        ctrl = $random % 7;
        data_in = $random % 255;
        
        // Random Test Case 5
        #10;
        clk = $random;
        rst = $random;
        ctrl = $random % 7;
        data_in = $random % 255;
        
    end
    

    // Monitor Outputs
    
    initial begin
        $monitor($time, " Outputs: data_out, status");
    end
    

endmodule

