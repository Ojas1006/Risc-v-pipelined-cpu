module imm_gen(
    input [31:0] instruction,
    output reg signed [31:0] immediate
);

wire [6:0]opcode = instruction[6:0];       //takes 7 bits to determine which type and format the instruction is in

always @(*) begin
        case(opcode)
            7'b0000011 , 7'b0010011 : immediate = {{20{instruction[31]}},instruction[31:20]};  //I-type
            7'b0100011 : immediate = {{20{instruction[31]}},instruction[31:25],instruction[11:7]}; //S-type
            7'b1100011 : immediate = {{19{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0}; //SB-type
            default : immediate = 32'b0;
        endcase
    end
endmodule