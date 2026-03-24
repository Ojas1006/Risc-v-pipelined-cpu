module forward_unit(
    input [4:0] rs_1, rs_2, //source registers from ID/EX
    input [4:0] rdmem, rdwb, //destination registers from EX/MEM and MEM/WB respectively
    input regwrite_wb, //MEM/WB.regwrite  checks if they write to a register
    input regwrite_mem, //EX/MEM.regwrite
    output reg [1:0] forward_a, forward_b //forwarding control signals for ALU inputs
);

always @(*) begin
    // Forward A
        if (regwrite_mem && (rdmem != 5'b0) && (rdmem == rs_1))
            forward_a = 2'b10;  // forward from EX/MEM
        else if (regwrite_wb && (rdwb != 5'b0) && (rdwb == rs_1))
            forward_a = 2'b01;  // forward from MEM/WB
        else
            forward_a = 2'b00;  // no forwarding

        // Forward B
        if (regwrite_mem && (rdmem != 5'b0) && (rdmem == rs_2))
            forward_b = 2'b10;  // forward from EX/MEM
        else if (regwrite_wb && (rdwb != 5'b0) && (rdwb == rs_2))
            forward_b = 2'b01;  // forward from MEM/WB
        else
            forward_b = 2'b00;  // no forwarding
end
endmodule