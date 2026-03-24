module ID_EX(
    input clk,
    input rst,
    input flush,
    input [31:0] readdata1_in, //from register file
    input [31:0] readdata2_in,
    input [31:0] immediate, //from immediate generator
    input [31:0] pc, // adder output carried forwarded from IF_ID
    input [4:0] rs1_in, //checks if there is a hazard
    input [4:0] rs2_in,
    input [4:0] rd_in, //passed all the way so register knows where to write back in later stages
    input branch,mem_read,mem_write,reg_write,mem_to_reg,alu_src,
    input [1:0] alu_op,
    input [3:0] funct4, //helps distinguish between different R type instructions that have the same opcode
    output reg [31:0] readdata1_out,
    output reg [31:0] readdata2_out,
    output reg [31:0] immediate_out,
    output reg [31:0] pc_out,
    output reg branch_out,mem_read_out,mem_write_out,reg_write_out,mem_to_reg_out,alu_src_out,
    output reg [1:0] alu_op_out,
    output reg [4:0] rs1_out,
    output reg [4:0] rs2_out,
    output reg [4:0] rd_out,
    output reg [3:0] funct4_out   //helps distinguish between different R type instructions that have the same opcode
);

always @(posedge clk) begin
    if (rst == 1'b1 || flush == 1'b1) begin
        readdata1_out <= 32'b0;
        readdata2_out <= 32'b0;
        immediate_out <= 32'b0;  
        pc_out <= 32'b0;
        branch_out <= 1'b0;
        mem_read_out <= 1'b0;   
        mem_write_out <= 1'b0;
        reg_write_out <= 1'b0;
        mem_to_reg_out <= 1'b0;
        alu_src_out <= 1'b0;
        alu_op_out <= 2'b00;
        rs1_out <= 5'b0;
        rs2_out <= 5'b0;
        rd_out <= 5'b0;
        funct4_out <= 4'b0;
    end

    else begin
        readdata1_out <= readdata1_in;
        readdata2_out <= readdata2_in;
        immediate_out <= immediate;  
        pc_out <= pc;
        branch_out <= branch;
        mem_read_out <= mem_read;   
        mem_write_out <= mem_write;
        reg_write_out <= reg_write;
        mem_to_reg_out <= mem_to_reg;
        alu_src_out <= alu_src;
        alu_op_out <= alu_op;
        rs1_out <= rs1_in;
        rs2_out <= rs2_in;
        rd_out <= rd_in;
        funct4_out <= funct4;
    end
end
endmodule