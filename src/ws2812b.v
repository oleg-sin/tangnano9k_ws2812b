module ws2812b (
    input wire clk,
    input wire reset,
    input wire write,
    input wire [23:0] rgb_data,
    input wire [7:0] led_num,

    output reg data
);

    parameter  CLK_MHZ  = 27;
    parameter  NUM_LEDS = 1;
    localparam LED_BITS = $clog2(NUM_LEDS);

    parameter  t_on     = $rtoi($ceil(CLK_MHZ * 850   / 1000));
    parameter  t_off    = $rtoi($ceil(CLK_MHZ * 430   / 1000));
    parameter  t_reset  = $rtoi($ceil(CLK_MHZ * 300));
    localparam t_period = $rtoi($ceil(CLK_MHZ * 1250  / 1000));

    localparam COUNT_BITS = $clog2(t_reset);

    reg [23:0] led_reg [NUM_LEDS-1:0];

    reg [  LED_BITS-1:0] led_counter;
    reg [COUNT_BITS-1:0] bit_counter;
    reg [           4:0] rgb_counter;

    localparam STATE_DATA  = 0;
    localparam STATE_RESET = 1;

    reg [1:0] state;

    reg [23:0] led_color;

    always @(posedge clk) begin
        if(write)
            led_reg[led_num] <= rgb_data;
        led_color <= led_reg[led_counter];
    end

    integer i;

    always @(posedge clk)
        if(reset) begin

            for(i = 0; i < NUM_LEDS; i = i + 1)
                led_reg[i] <= 0;

            state <= STATE_RESET;
            bit_counter <= t_reset;
            rgb_counter <= 23;
            led_counter <= NUM_LEDS - 1;
            data <= 0;

        end else case(state)
            STATE_RESET: begin
                rgb_counter <= 5'd23;
                led_counter <= NUM_LEDS - 1;
                data <= 0;

                bit_counter <= bit_counter - 1;

                if(bit_counter == 0) begin
                    state <= STATE_DATA;
                    bit_counter <= t_period;
                end
            end

            STATE_DATA: begin
                if(led_color[rgb_counter])
                    data <= bit_counter > (t_period - t_on);
                else
                    data <= bit_counter > (t_period - t_off);

                bit_counter <= bit_counter - 1;

                if(bit_counter == 0) begin
                    bit_counter <= t_period;
                    rgb_counter <= rgb_counter - 1;

                    if(rgb_counter == 0) begin
                        led_counter <= led_counter - 1;
                        bit_counter <= t_period;
                        rgb_counter <= 23;

                        if(led_counter == 0) begin
                            state <= STATE_RESET;
                            led_counter <= NUM_LEDS - 1;
                            bit_counter <= t_reset;
                        end
                    end
                end
            end
        endcase
endmodule