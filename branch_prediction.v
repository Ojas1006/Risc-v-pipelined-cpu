module branch_prediction(
    input [2:0] funct3,
    input [31:0] readData1,
    input [31:0] b,
    output reg addermuxselect
);

always @(*) begin
    case(funct3) 
        3'b000: addermuxselect = (readData1 == b) ? 1 : 0; // beq
        3'b001: addermuxselect = (readData1 != b) ? 1 : 0; // bne
        3'b100: addermuxselect = ($signed(readData1) < $signed(b)) ? 1 : 0; // blt
        3'b101: addermuxselect = ($signed(readData1) >= $signed(b)) ? 1 : 0; // bge
        default: addermuxselect = 0;
    endcase
end
endmodule