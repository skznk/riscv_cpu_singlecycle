`timescale 10ns/1ps

module top_mod;

reg clock;
reg reset;
wire wr;
assign wr = 1;
wire [63:0]pc;
wire [63:0]pc_plus4;
wire [63:0]next_pc;
wire [31:0]instruction;
wire [6:0]instructionType;
wire A_select;
wire B_select;
wire [3:0]alu_Operation;
wire memory_read_en;
wire memory_write_en;
wire reg_write_en;
wire [2:0]wb_select;
wire [1:0]pc_select;
wire [2:0]br_condition;
wire [2:0]store_width;
wire [2:0]load_width;
wire [63:0]amuxOutput;
wire [63:0]bmuxOutput;
wire [63:0]immediate;
wire [63:0] alu_result;
wire brTakenBool;
wire [4:0]rs1Location;
wire [4:0]rs2Location;
wire [4:0]rdLocation;
wire [63:0]rs1;
wire [63:0]rs2;
wire [63:0]rd;
wire [63:0]wbout;
reg [63:0] rd_reg;
reg [4:0]  rd_id_reg;
reg        wr_en_reg;

initial begin
  clock = 0;
end

always #2 clock = ~clock;

initial begin
  reset = 1;
  #5 reset = 0;
end


initial begin
  // Wait for instruction to stabilize
    #4
$monitor("Time=%0t PC=%h INSTR=%h INSTR_TYPE=%b RS1=%h RS2=%h RD=%h WB=%h WB_SEL=%d ALU=%h AMUX=%h BMUX=%h IMM=%h", 
        $time, pc, instruction, instructionType, rs1, rs2, rd, wbout, wb_select, alu_result, amuxOutput, bmuxOutput, immediate );
  #200 $finish;
end

always @(posedge clock) begin
  if (pc == 64'h0000000000000030) begin
    $display("Program finished at PC = %h", pc);
    $finish;
  end
end



always @(posedge clock) begin
    rd_reg     <= wbout;
    rd_id_reg  <= rdLocation;
    wr_en_reg  <= reg_write_en;
end



//FETCH TO DECODE and MEMORY
pcREG pcP(clock, wr, reset, next_pc, pc);
mems mes(clock, pc, store_width, load_width, memory_read_en, memory_write_en, alu_result, rs1, rs2 ,instruction, rd);
instructRegs gprInputs(instruction, instructionType, rs1Location, rs2Location, rdLocation);
gprs GPR(clock, wr_en_reg, rd_reg, rd_id_reg, rs1Location, rs2Location, rs1, rs2);
immediateGenerator immGEN(instruction, immediate);

//AGEX
Amux aSel(pc, rs1, A_select, amuxOutput);
Bmux Bsel(rs2, immediate, B_select, bmuxOutput);

alu infamousALU(amuxOutput, bmuxOutput, alu_Operation, alu_result);

brCMP cond(rs1, br_condition, rs2, brTakenBool);
control log(instruction, instructionType, A_select, B_select, alu_Operation, memory_read_en, memory_write_en, reg_write_en, wb_select, pc_select, br_condition, store_width, load_width);



pcAdd4Mux add4mux(wr, pc, pc_plus4); 
PC_MUX pmux(pc_plus4, alu_result, pc_select, next_pc);
WB_MUX wbM(pc_plus4, alu_result, rd, wb_select, wbout);








endmodule