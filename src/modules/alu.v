module ALU(
    input [31:0] a,b,
    input [3:0] ALUCtl,
    output reg [31:0] result,
    output zero
); 

assign zero = (result == 32'b0) ? 1'b1 : 1'b0;

always @(*) begin
    case(ALUCtl)
        4'd0: result = a+b;  //add
        4'd1: result = a-b; //sub
        4'd2: result = a & b; //and
        4'd3: result = a | b; //or
        4'd4: result = a << b[4:0]; //sll
        4'd5: result = {31'b0,{$signed(a)<$signed(b)?1'b1:1'b0}}; //slt
        4'd6: result = {31'b0,{(a) < (b)? 1'b1 : 1'b0}}; //sltu
        4'd7: result = a ^ b; //xor
        4'd8: result = a >> b[4:0]; //srl
        4'd9: result = $signed(a) >>> b[4:0]; //sra - keeps the sign bit of a and shifts it to the right
        4'd10: result = b; //lui - pass B through ALU
        default: result = 32'b0;
    endcase
end
endmodule