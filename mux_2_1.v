module mux_2_1 (
    input [31:0] in0,
    input [31:0] in1,
    input sel,
    output reg [31:0] out
);

always @(*) begin
    case(sel)
        1'b0: out = in0;
        1'b1: out = in1;
        default : out = 32'b0;
    endcase
    end
endmodule   