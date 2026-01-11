
module gprs(input clk, input wr_en, input [63:0]rd, input [4:0]rd_id, input [4:0]r1_id, input [4:0]r2_id, output wire [63:0]r1, output wire [63:0]r2);

reg [63:0] register [31:0];


always @(posedge clk) begin  //Updates the specific register (rd) with a value
    register[0] <= 64'd0;
    if (wr_en && rd_id != 5'd0)begin
        register[rd_id] <= rd;
        $display("WRITE: Time=%0t Register[%0d] <= %h", $time, rd_id, rd);
    end
    register[0] <= 64'd0;

end

assign r1 = (wr_en && rd_id != 0 && rd_id == r1_id) ? rd : register[r1_id];
assign r2 = (wr_en && rd_id != 0 && rd_id == r2_id) ? rd : register[r2_id];


endmodule

module instructRegs(input [31:0]inst, input [6:0]instructType, output reg [4:0]rs1Loc, output reg [4:0]rs2Loc, output reg [4:0]rdLoc);

//INSTRUCTION TYPES
localparam REGISTER_TYPE = 7'b0110011;
localparam IMMEDIATE_TYPE = 7'b0010011;
localparam LOAD_TYPE = 7'b0000011;
localparam STORE_TYPE = 7'b0100011;
localparam BRANCH_TYPE = 7'b1100011;
localparam J_TYPE = 7'b1101111;
localparam U_TYPE_LUI = 7'b0110111;
localparam U_TYPE_AUIPC = 7'b0010111;

always @(*) begin //Determining the registers that are being used based on the instruction type
    
    case (instructType)
        REGISTER_TYPE: begin
        rs1Loc = inst[19:15];
        rs2Loc = inst[24:20];
        rdLoc = inst[11:7];
        end
        IMMEDIATE_TYPE: begin
        rs1Loc = inst[19:15];
        rs2Loc = 5'd0;
        rdLoc = inst[11:7];
        end
        LOAD_TYPE: begin
        rs1Loc = inst[19:15];
        rs2Loc = 5'd0;
        rdLoc = inst[11:7];
        end
        STORE_TYPE: begin
        rs1Loc = inst[19:15];
        rs2Loc = inst[24:20];
        rdLoc = 5'd0;
        end
        BRANCH_TYPE: begin
        rs1Loc = inst[19:15];
        rs2Loc = inst[24:20];
        rdLoc = 5'd0;
        end
        J_TYPE: begin
        rs1Loc = 5'd0;
        rs2Loc = 5'd0;
        rdLoc = inst[11:7];
        end
        U_TYPE_LUI: begin
        rs1Loc = 5'd0;
        rs2Loc = 5'd0;
        rdLoc= inst[11:7];
        end
        U_TYPE_AUIPC: begin
        rs1Loc = 5'd0;
        rs2Loc = 5'd0;
        rdLoc= inst[11:7];
        end
        
    endcase



end

endmodule

module immediateGenerator (input [31:0]instruction, output reg [63:0]immediateFinal);

localparam I_TYPE = 7'b0010011;
localparam S_TYPE = 7'b0100011;
localparam B_TYPE = 7'b1100011;
localparam J_TYPE = 7'b1101111;
localparam U_TYPE_LUI = 7'b0110111;
localparam U_TYPE_AUIPC = 7'b0010111;

wire [6:0]code;
assign code = instruction[6:0]; //Instruction type

always @(*) begin //Determines the immediate based on the instruction type
    if ((instruction ^ instruction) === 32'b0 && (code ^ code) === 7'b0) begin // Checks if any bit from instruction or code is equal to X, if it isn't then the if statement is true
        case(code)
            I_TYPE:
                immediateFinal = { {52{instruction[31]}}, instruction[31:20]};
            S_TYPE:
                immediateFinal = { {52{instruction[31]}}, instruction[31:25], instruction[11:7]};
            B_TYPE:
                immediateFinal = { {51{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            J_TYPE:
                immediateFinal = { {43{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0} ;
            U_TYPE_LUI:begin
                immediateFinal = {{32{instruction[31]}}, instruction[31:12], 12'd0};
            end
            U_TYPE_AUIPC:
                immediateFinal = {{32{instruction[31]}}, instruction[31:12], 12'd0};
            default:
                immediateFinal = 64'd0;
        endcase
    end 
    else begin //For any unstable instructions
        immediateFinal = 64'd0; // Immediate default if things are unstable
    end
end


endmodule