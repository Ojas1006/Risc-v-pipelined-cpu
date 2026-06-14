module pipeline_flush(
    input branch,
    input jump,
    input zero,
    output reg flush_ifid,
    output reg flush_idex,
    output reg flush_exmem
);

initial begin
    flush_ifid = 1'b0;
    flush_idex = 1'b0;
    flush_exmem = 1'b0;
end

always @(*) begin
    flush_ifid = (branch & zero) | jump;
    flush_idex = (branch & zero) | jump;
    flush_exmem = (branch & zero);
end
endmodule