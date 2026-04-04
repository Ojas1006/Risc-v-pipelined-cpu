module alu_control (
    input  [1:0] ALUOp,
    input  [3:0] funct,
    output reg [3:0] operation
);

always @(*) begin
    case (ALUOp)
        2'b00: operation = 4'd0;  // Load/Store → ADD

        2'b01: begin              
            casez (funct)
                4'b?000: operation = 4'd1;  // BEQ  (SUB)
                4'b?001: operation = 4'd1;  // BNE  (SUB)
                4'b?100: operation = 4'd5;  // BLT  (SLT)
                4'b?101: operation = 4'd5;  // BGE  (SLT)
                4'b?110: operation = 4'd6;  // BLTU (SLTU)
                4'b?111: operation = 4'd6;  // BGEU (SLTU)
                default: operation = 4'd1;
            endcase
        end

        2'b10: begin              // R-type / I-type → decode funct
            casez (funct)
                4'b0000: operation = 4'd0;  // ADD
                4'b1000: operation = 4'd1;  // SUB
                4'b?001: operation = 4'd4;  // SLL
                4'b?010: operation = 4'd5;  // SLT
                4'b?011: operation = 4'd6;  // SLTU
                4'b?100: operation = 4'd7;  // XOR
                4'b0101: operation = 4'd8;  // SRL
                4'b1101: operation = 4'd9;  // SRA
                4'b?110: operation = 4'd3;  // OR
                4'b?111: operation = 4'd2;  // AND
                default: operation = 4'd0;
            endcase
        end
        
        2'b11: operation = 4'd10;  // LUI → pass B through ALU
        default: operation = 4'd0;
    endcase
end

endmodule