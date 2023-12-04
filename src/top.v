module top (
    input clk,
    input rst_n,
    output ws_data
);

    localparam MATRIX_W = 5;
    localparam MATRIX_H = 5;
    localparam NUM_LEDS = MATRIX_W * MATRIX_H;

    localparam SATURATION = 8'd255;
    localparam VALUE      = 8'd20;

    reg reset = 1;
    always @(posedge clk)
        reset <= 0;

    reg [19:0] count = 0;
    reg [7:0] color_ind = 0;

    reg [3:0] x = 0;
    reg [3:0] y = 0;

    reg state_inhalation = 0;
    reg state_exhalation = 1;
    reg [1:0] state = 1;
    reg [12:0] state_count = 0;
    reg [4:0] breathe_count = 20;
    reg [7:0] breathe_value = VALUE;

    always @(posedge clk) begin
            count <= count + 1;
            if (&count) begin
                case (state)
                state_exhalation: begin
                    breathe_count <= breathe_count - 1;
                    breathe_value <= breathe_value + 3;
                    if (breathe_count == 0) begin
                        state <= state_inhalation;
                        breathe_count <= 20;
                    end
                end
                state_inhalation: begin
                    breathe_count <= breathe_count - 1;
                    breathe_value <= breathe_value - 3;
                    if (breathe_count == 0) begin
                        state <= state_exhalation;
                        breathe_count <= 20;
                    end
                end
                endcase
                V <= breathe_value;
                x <= x + 1;
                
                if (x == MATRIX_W - 1) begin
                    y <= y + 1;
                    x <= 0;
                    color_ind <= color_ind + 51;
                    if (y == MATRIX_H - 1) begin
                        y <= 0;
                        color_ind <= 0;
                    end
                end
            end else begin
                
            end
            led_num <= matrix_led_num;
            H <= color_ind;
            S <= SATURATION;
            

        state_count <= state_count + 1;
        if (&state_count) begin
            
        end else begin
            state_count <= 0;
            //breathe_value <= VALUE;
        end
    end

    wire [23:0] led_rgb_data;
    reg [7:0] led_num;
    wire led_write = &count;

    ws2812b #(.NUM_LEDS(NUM_LEDS)) ws2812b_inst (
        .data(ws_data),
        .clk(clk),
        .reset(reset),
        .rgb_data(led_rgb_data),
        .led_num(led_num),
        .write(led_write)
    );

    reg [7:0] H = 0;
    reg [7:0] S = 0;
    reg [7:0] V = VALUE;

    hsv_to_rgb hsv_to_rgb_inst (
        .H(H),
        .S(S),
        .V(V),
        .clk(clk),
        .rgb(led_rgb_data)
    );

    wire [7:0] matrix_led_num;

    XY_to_num_led  #(.MATRIX_W(MATRIX_W), .MATRIX_H(MATRIX_H)) XY_to_num_led_inst (
        .x(x),
        .y(y),
        .clk(clk),
        .num_led(matrix_led_num)
    );

endmodule