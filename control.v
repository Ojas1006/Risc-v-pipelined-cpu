module control(
    input [6:0] opcode,
    input stall,
    output reg branch,
    output reg mem_read,
    output reg mem_write,
    output reg reg_write,
    output reg mem_to_reg,
    output reg [1:0] alu_op,
    output reg alu_src
);

always @(*) begin

    branch = 1'b0;
    mem_read = 1'b0;
    mem_write = 1'b0;
    reg_write = 1'b0;
    mem_to_reg = 1'b0;
    alu_src = 1'b0;
    alu_op = 2'b00;

    case(opcode) 
        7'b0110011: begin       //R-type
            branch = 1'b0;
            mem_read = 1'b0;
            mem_write = 1'b0;
            reg_write = 1'b1;
            mem_to_reg = 1'b0;
            alu_src = 1'b0;
            alu_op = 2'b10;
        end

        7'b0000011: begin       //I-type (load)
            branch = 1'b0;
            mem_read = 1'b1;
            mem_write = 1'b0;
            reg_write = 1'b1;
            mem_to_reg = 1'b1;
            alu_src = 1'b1;
            alu_op = 2'b00;
        end

        7'b0100011: begin       //S-type (store)
            branch = 1'b0;
            mem_read = 1'b0;
            mem_write = 1'b1;
            reg_write = 1'b0;
            mem_to_reg = 1'b0; //don't care but we use 0
            alu_src = 1'b1;
            alu_op = 2'b00;
        end

        7'b1100011 : begin      //SB-type (branch)
            branch = 1'b1;
            mem_read = 1'b0;
            mem_write = 1'b0;
            reg_write = 1'b0;
            mem_to_reg = 1'b0; //don't care but we use 0 
            alu_src = 1'b0;
            alu_op = 2'b01;
        end

         7'b0010011 : begin      //I-type (ALU immediate instructions)
            branch = 1'b0;
            mem_read = 1'b0;
            mem_write = 1'b0;
            reg_write = 1'b1;
            mem_to_reg = 1'b0;
            alu_src = 1'b1;
            alu_op = 2'b10;
        end

        default: begin
            branch = 1'b0;
            mem_read = 1'b0;
            mem_write = 1'b0;
            reg_write = 1'b0;
            mem_to_reg = 1'b0;
            alu_src = 1'b0;
            alu_op = 2'b00;
        end
    endcase

    if (stall == 1'b1) begin
        branch = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        reg_write = 1'b0;
        mem_to_reg = 1'b0;
        alu_src = 1'b0;
        alu_op = 2'b00;
    end

end
endmodule