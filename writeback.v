module PC_MUX(input [63:0]pc_added_4, input [63:0]alu_result, input [1:0]pc_sel, output reg [63:0]pc_result);

localparam PC_PLUS_4 = 2'd1;
localparam PC_ALU = 2'd0;

always @(*) begin //Determines the pc behavior of the instruction.

    case (pc_sel)
    PC_PLUS_4:
    pc_result = pc_added_4;
    PC_ALU:
    pc_result = alu_result;
    default:
    pc_result = pc_added_4;
    endcase 


end

endmodule


module WB_MUX(input [63:0]pc_added_4, input [63:0]alu_result, input [63:0]mem, input [2:0]wb_sel, output wire [63:0]wb_out); //Deterines the writeback muxes behavior

localparam WB_ALU = 3'd2;
localparam WB_PC = 3'd1;
localparam WB_MEM = 3'd0;

assign wb_out = (wb_sel == WB_PC)  ? pc_added_4 :  (wb_sel == WB_ALU) ? alu_result :(wb_sel == WB_MEM) ? mem : 64'd0;


endmodule

module pcAdd4Mux(input wr_en, input [63:0]cur_pc, output reg [63:0]next_pc); // pc plus 4 mux

wire [63:0]outAdd;
localparam four = 64'd4;

KoggeStone pcP4(cur_pc, four, outAdd); // Koggestone adding the pc plus 4, slightly overkill but does the job

always @(*) begin
    if (wr_en) 
    next_pc = outAdd;
    else
    next_pc = cur_pc;
end

endmodule