module RISC_V_pipeline(
    input clk,
    input reset
);

wire stall;
wire flush;
//register file
wire [31:0] readdata1, readdata2;
wire [31:0] write_data;

//control signals
wire branch;
wire memread;
wire memtoreg;
wire [1:0] ALUOp;
wire memWrite;
wire alusrc;
wire regWrite;

//program counter
wire [31:0] pc_in;
wire [31:0] pc_out;

// adders
wire [31:0] adderout1;
wire [31:0] adderout2;

// instruction memory
wire [31:0] instruction;
wire [31:0] inst_ifid_out;

wire [6:0] opcode;
wire [4:0] rd,rs1,rs2;
wire[2:0] funct3;
wire [6:0] funct7;

// immediate generator
wire [31:0] imm_data;

wire [31:0] random; // carries pc+4 ahead

//ID/EX wires
wire [31:0] a1; //PC+4 from ID/EX (for branch adder in EX)
wire [4:0] RS1; 
wire [4:0] RS2; //for fowarding unit
wire [4:0] RD; //passed to later stages for write back
wire [31:0] imm_idex; //passed to later stages for ALU src2
wire [31:0] readData1; //passed to later stages for ALU src1
wire [31:0] readData2; //passed to later stages for ALU src2

wire Branch, MemRead, MemtoReg, MemWrite, ALUsrc, RegWrite;
wire [1:0] ALUOp_idex;

wire [3:0] funct4_out; //for ALU control

// 3 to 1 MUX and ALU input wires
wire [31:0] three_to_one_out1;
wire [31:0] three_to_one_out2;
wire [31:0] alu_32_b; //final ALU B input after MUX

//EX/MEM wires
wire [31:0] write_Data; //rs2 value forwarded to MEM stage for sw
wire [31:0] adder_exmem_out; //branch target address from EX stage adder
wire exmem_zero; //zero flag from EX stage ALU
wire [31:0] alu_exmem_out; //ALU result from EX stage
wire [4:0] rd_exmem; //destination register number passed to MEM stage for write back

wire BRANCH, MEMREAD, MEMTOREG, MEMWRITE, REGWRITE;

//ALU
wire [31:0] alu_result; 
wire zero;
wire [3:0] operation; //ALU control signal

//Data memory
wire [31:0] readdata; //data read from memory

//MEM/WB wires
wire [31:0] muxin1; // ALU result carried into WB stage (for R/I-type writeback)
wire [31:0] muxin2; // Memory read data carried into WB stage (for load writeback)
wire [4:0]  memwbrd; // rd index finally used to address the register file write port
wire memwb_memtoreg; // Selects muxin1 vs muxin2 → produces write_data
wire memwb_regwrite; //Enables write

//Forwarding unit
wire [1:0] forwardA;
wire [1:0] forwardB;

//branch decision
wire addermuxselect;
wire branch_final; 
wire [31:0] branch_target;
assign branch_target = (a1 - 32'd4) + imm_idex;  // PC + imm - 4 because a1 is already PC+4

pipeline_flush p_flush (
    .branch(addermuxselect & Branch),
    .flush(flush)
);

hazard_detection hu (
    .instruction(inst_ifid_out),
    .mem_read_ex(MemRead),
    .rd(RD),
    .stall(stall)
);

program_counter pc (
    .pc_in(pc_in),
    .clk(clk),
    .reset(reset),
    .stall(stall),
    .pc_out(pc_out)
);

instruction_memory im(
    .readAddr(pc_out),
    .inst(instruction)
);

adder adder1 (
    .a(pc_out),
    .b(32'd4),
    .sum(adderout1)
);

IF_ID if_id (
    .clk(clk),
    .rst(reset),
    .flush(flush),
    .instruction(instruction),
    .pc(adderout1),
    .inst_write(stall),
    .inst(inst_ifid_out),
    .pc_out(random)
);

parser p(
    .instruction(inst_ifid_out),
    .opcode(opcode),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .funct3(funct3),
    .funct7(funct7)
);

control cu (
    .opcode(opcode),
    .stall(stall),
    .branch(branch),
    .mem_read(memread),
    .mem_write(memWrite),
    .reg_write(regWrite),
    .mem_to_reg(memtoreg),
    .alu_op(ALUOp),
    .alu_src(alusrc)
);

imm_gen ig (
    .instruction(inst_ifid_out),
    .immediate(imm_data)
);

register registerfile(
    .clk(clk),
    .rst(reset),
    .regwrite(memwb_regwrite),
    .readreg1(rs1),
    .readreg2(rs2),
    .writereg(memwbrd),
    .writedata(write_data),
    .readdata1(readdata1),
    .readdata2(readdata2)
);

ID_EX id_ex(
    .clk(clk),
    .rst(reset),
    .flush(flush),
    .readdata1_in(readdata1),
    .readdata2_in(readdata2),
    .immediate(imm_data),
    .pc(random),
    .rs1_in(rs1),
    .rs2_in(rs2),
    .rd_in(rd),
    .branch(branch),
    .mem_read(memread),
    .mem_write(memWrite),
    .reg_write(regWrite),
    .mem_to_reg(memtoreg),
    .alu_src(alusrc),
    .alu_op(ALUOp),
    .funct4({inst_ifid_out[30], inst_ifid_out[14:12]}), //funct4 is a combination of the funct3 and the most significant bit of funct7, which helps distinguish between different R-type instructions that have the same opcode
    .readdata1_out(readData1),
    .readdata2_out(readData2),
    .immediate_out(imm_idex),
    .pc_out(a1),
    .branch_out(Branch),
    .mem_read_out(MemRead),
    .mem_write_out(MemWrite),
    .reg_write_out(RegWrite),
    .mem_to_reg_out(MemtoReg),
    .alu_src_out(ALUsrc),
    .alu_op_out(ALUOp_idex),
    .rs1_out(RS1),
    .rs2_out(RS2),
    .rd_out(RD),
    .funct4_out(funct4_out)
);

adder adder2 (
    .a(a1),
    .b(imm_idex), //shift immediate left by 1 for branch target calculation
    .sum(adderout2)
);

mux_3_1 m1(
    .in0(readData1),
    .in1(write_data),
    .in2(alu_exmem_out),
    .sel(forwardA),
    .out(three_to_one_out1)
);

mux_3_1 m2(
    .in0(readData2),
    .in1(write_data),
    .in2(alu_exmem_out),
    .sel(forwardB),
    .out(three_to_one_out2)
);

mux_2_1 mux_alu(
    .in0(three_to_one_out2),
    .in1(imm_idex),
    .sel(ALUsrc),
    .out(alu_32_b)
);

ALU alu(
    .a(three_to_one_out1),
    .b(alu_32_b),
    .ALUCtl(operation),
    .result(alu_result),
    .zero(zero)
);

alu_control ac (
    .funct(funct4_out),
    .ALUOp(ALUOp_idex),
    .operation(operation)
);

EX_MEM ex_mem(
    .clk(clk),
    .rst(reset),
    .alu_result_in(alu_result),
    .zero_in(zero),
    .writedata_in(three_to_one_out2),
    .rd_in(RD),
    .adder_in(adderout2),
    .branch(Branch),
    .mem_read(MemRead),
    .mem_write(MemWrite),
    .reg_write(RegWrite),
    .mem_to_reg(MemtoReg),
    .addermuxselect_in(addermuxselect),
    .alu_result_out(alu_exmem_out),
    .zero_out(exmem_zero),
    .writedata_out(write_Data),
    .rd_out(rd_exmem),
    .adder_out(adder_exmem_out),
    .branch_out(BRANCH),
    .mem_read_out(MEMREAD),
    .mem_write_out(MEMWRITE),
    .reg_write_out(REGWRITE),
    .mem_to_reg_out(MEMTOREG),
    .addermuxselect_out(branch_final) 
);

data_memory dm(
    .clk(clk),
    .mem_read(MEMREAD),
    .mem_write(MEMWRITE),
    .address(alu_exmem_out),
    .write_data(write_Data),
    .read_data(readdata)
);

wire pc_sel;
assign pc_sel = addermuxselect & BRANCH; //final branch decision is made here by combining the zero flag from the ALU with the branch control signal from the EX/MEM pipeline register

mux_2_1 mu(
    .in0(adderout1),               // PC+4 from IF stage adder
    .in1(branch_target),           // Branch target address from EX stage adder
    .sel(pc_sel),
    .out(pc_in)
);

MEM_WB mem_wb(
    .clk(clk),
    .rst(reset),
    .alu_result_in(alu_exmem_out),
    .mem_data_in(readdata),
    .rd_in(rd_exmem),
    .reg_write_in(REGWRITE),
    .mem_to_reg_in(MEMTOREG),
    .alu_result_out(muxin1),
    .mem_data_out(muxin2),
    .rd_out(memwbrd),
    .reg_write_out(memwb_regwrite),
    .mem_to_reg_out(memwb_memtoreg)
);

mux_2_1 m4(
    .in0(muxin1),
    .in1(muxin2),
    .sel(memwb_memtoreg),
    .out(write_data)
);

forward_unit fu(
    .rs_1(RS1),
    .rs_2(RS2),
    .rdmem(rd_exmem),
    .rdwb(memwbrd),
    .regwrite_wb(memwb_regwrite),
    .regwrite_mem(REGWRITE),
    .forward_a(forwardA),
    .forward_b(forwardB)
);

branch_prediction bp(
    .funct3(funct4_out[2:0]),
    .readData1(three_to_one_out1),
    .b(three_to_one_out2),
    .addermuxselect(addermuxselect)
);

endmodule



