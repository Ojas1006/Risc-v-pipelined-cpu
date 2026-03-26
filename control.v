module control(
    input [6:0] opcode,
    input stall,
    output reg branch,
    output reg mem_read,
    output reg mem_write,
    output reg reg_write,
    output reg [1:0] mem_to_reg,  //after adding jump mux has now 3 wb options to choose from
    output reg [1:0] alu_op,
    output reg alu_src,
    output reg jump,
    output reg jalr
);

always @(*) begin

    branch = 1'b0;
    mem_read = 1'b0;
    mem_write = 1'b0;
    reg_write = 1'b0;
    mem_to_reg = 2'b00;
    alu_src = 1'b0;
    alu_op = 2'b00;
    jump = 1'b0;
    jalr = 1'b0;

    casez(opcode)
        7'b0110011: begin       //R-type
            branch = 1'b0;
            mem_read = 1'b0;
            mem_write = 1'b0;
            reg_write = 1'b1;
            mem_to_reg = 2'b00;
            alu_src = 1'b0;
            alu_op = 2'b10;
            jump = 1'b0;
            jalr = 1'b0;
        end

        7'b0000011: begin       //I-type (load)
            branch = 1'b0;
            mem_read = 1'b1;
            mem_write = 1'b0;
            reg_write = 1'b1;
            mem_to_reg = 2'b01;
            alu_src = 1'b1;
            alu_op = 2'b00;
            jump = 1'b0;
            jalr = 1'b0;
        end

        7'b0100011: begin       //S-type (store)
            branch = 1'b0;
            mem_read = 1'b0;
            mem_write = 1'b1;
            reg_write = 1'b0;
            mem_to_reg = 2'b00; //don't care but we use 0
            alu_src = 1'b1;
            alu_op = 2'b00;
            jump = 1'b0;
            jalr = 1'b0;
        end

        7'b1100011 : begin      //SB-type (branch)
            branch = 1'b1;
            mem_read = 1'b0;
            mem_write = 1'b0;
            reg_write = 1'b0;
            mem_to_reg = 2'b00; //don't care but we use 0 
            alu_src = 1'b0;
            alu_op = 2'b01;
            jump = 1'b0;
            jalr = 1'b0;
        end

         7'b0010011 : begin      //I-type (ALU immediate instructions)
            branch = 1'b0;
            mem_read = 1'b0;
            mem_write = 1'b0;
            reg_write = 1'b1;
            mem_to_reg = 2'b00;
            alu_src = 1'b1;
            alu_op = 2'b10;
            jump = 1'b0;
            jalr = 1'b0;
        end

        7'b110?111: begin
            reg_write = 1'b1;
            mem_read = 1'b0;
            mem_write = 1'b0;
            mem_to_reg = 2'b10;
            alu_op = 2'b00;
            branch = 1'b0;
            jump = 1'b1;
            case(opcode[3])
                1'b1: begin
                    alu_src = 1'b0;
                    jalr = 1'b0;
                end

                1'b0: begin
                    alu_src = 1'b1;
                    jalr = 1'b1;
                end
            endcase
        end

        7'b0110111: begin
            branch = 1'b0;
            mem_read = 1'b0;
            mem_write = 1'b0;
            reg_write = 1'b1;
            mem_to_reg = 2'b00;
            alu_src = 1'b1;
            alu_op = 2'b11;
            jump = 1'b0;
            jalr = 1'b0;
        end

        default: begin
            branch = 1'b0;
            mem_read = 1'b0;
            mem_write = 1'b0;
            reg_write = 1'b0;
            mem_to_reg = 2'b00;
            alu_src = 1'b0;
            alu_op = 2'b00;
            jump = 1'b0;
            jalr = 1'b0;
        end
    endcase

    if (stall == 1'b1) begin
        branch = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        reg_write = 1'b0;
        mem_to_reg = 2'b00;
        alu_src = 1'b0;
        alu_op = 2'b00;
        jump = 1'b0;
        jalr = 1'b0;
    end

end
endmodule