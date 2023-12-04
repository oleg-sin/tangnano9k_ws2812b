module hsv_to_rgb (
    input       [7:0]  H, S, V,
    input              clk,
    output reg [23:0] rgb
);
    integer P, Q, T, region, remainder;
    reg [7:0] R, G, B;
    always @(posedge clk) begin
        region <= H / 43;
        remainder <= (H - (region * 43)) * 6;
        P <= (V * (255 - S)) >> 8;
        Q <= (V * (255 - ((S * remainder) >> 8))) >> 8;
        T <= (V * (255 - ((S * (255 - remainder)) >> 8))) >> 8;

        case (region)
            3'd0    : begin R <= V; G <= T; B <= P; end
            3'd1    : begin R <= Q; G <= V; B <= P; end
            3'd2    : begin R <= P; G <= V; B <= T; end
            3'd3    : begin R <= P; G <= Q; B <= V; end
            3'd4    : begin R <= T; G <= P; B <= V; end
            default : begin R <= V; G <= P; B <= Q; end
        endcase
        rgb <= {G, R, B}; // ws2812b have a GRB color order
    end
endmodule