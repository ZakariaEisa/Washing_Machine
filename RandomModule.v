module RAN(
    input clk,
    input rst,
    input [2:0] ctrl,
    input [7:0] data_in,
    output reg [7:0] data_out,
    output reg [7:0] status
);

    reg [7:0] temp;
    reg enable;

    assign status = (rst) ? 8'b00000010 : 8'b00000000;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_out <= 8'b0;
            temp <= 8'b0;
            enable <= 0;
        end else begin
            case (ctrl)
                3'b001: begin
                    data_out <= data_in - 1;
                    temp <= data_in - 1;
                    enable <= 1;
                end
                3'b010: begin
                    data_out <= data_in + 2;
                    temp <= data_in + 2;
                    enable <= 1;
                end
                3'b011: begin
                    data_out <= data_in ^ 8'hFF; // Invert bits of data_in
                    temp <= data_in ^ 8'hFF;
                    enable <= 0;
                end
                default: begin
                    data_out <= 8'b00000000;
                    temp <= 8'b00000000;
                    enable <= 0;
                end
            endcase
        end
    end
endmodule
