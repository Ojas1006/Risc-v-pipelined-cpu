module alu_control (
    input  [1:0] ALUOp,
    input  [3:0] funct,
    output reg [3:0] operation
);

always @(*) begin
    case (ALUOp)
        2'b00: operation = 4'd0;  // Load/Store → ADD
        2'b01: operation = 4'd1;  // Branch     → SUB

        2'b10: begin              // R-type / I-type → decode funct
            case (funct)
                4'b0000: operation = 4'd0;  // ADD (add, addi)
                4'b1000: operation = 4'd1;  // SUB
                4'b0111: operation = 4'd2;  // AND
                4'b0110: operation = 4'd3;  // OR
                default: operation = 4'd0;
            endcase
        end
        
        2'b11: operation = 4'd10;  // LUI → pass B through ALU
        default: operation = 4'd0;
    endcase
end

endmodule