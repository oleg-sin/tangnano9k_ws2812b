module XY_to_num_led (
        input [3:0] x, y,
        input clk,
        output reg [7:0] num_led
);
        parameter MATRIX_W = 5;
        parameter MATRIX_H = 5;

        reg [3:0] reverse_x;

        always @(posedge clk) begin
            if (y & 1'b1) begin
                reverse_x <= (MATRIX_W - 1) - x;
                num_led <= (y * MATRIX_W) + reverse_x;
            end else begin
                num_led <= (y * MATRIX_W) + x;
            end
        end
endmodule