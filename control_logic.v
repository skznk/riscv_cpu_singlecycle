//Control logic of the instruction
module control(input [31:0]inst, output [6:0]wInstype, output wA_sel, output wB_sel, output [9:0]wAlu_op, output wMem_read_en, output wMem_write_en, output wReg_write_en, output [2:0]wWb_sel, output [1:0]wPc_sel, output [2:0]wBr_cond, output [2:0]wStore_width, output [2:0]wLoad_width);
//TYPES
localparam REGISTER_TYPE = 7'b0110011;
localparam IMMEDIATE_TYPE = 7'b0010011;
localparam LOAD_TYPE = 7'b0000011;
localparam STORE_TYPE = 7'b0100011;
localparam BRANCH_TYPE = 7'b1100011;
localparam J_TYPE = 7'b1101111;
localparam U_TYPE_LUI = 7'b0110111;
localparam U_TYPE_AUIPC = 7'b0010111;
//REGISTER WRITE ENABLE/DISABLE
localparam REG_WRITE_EN = 2'd1;
localparam REG_WRITE_DIS = 2'd0;
//A SEL
localparam A_SEL_PC = 2'd1;
localparam A_SEL_RS1 = 2'd0;
//B SEL
localparam B_SEL_RS2 = 2'd1;
localparam B_SEL_IMM = 2'd0;
//BR COND
localparam BR_EQ = 3'd0;
localparam BR_NEQ = 3'd1;
localparam BR_LT = 3'd4;
localparam BR_GE = 3'd5;
localparam BR_LTU = 3'd6;
localparam BR_GEU = 3'd7;
//ALU OP
localparam ALU_AND = 10'd7;
localparam ALU_OR = 10'd6;
localparam ALU_XOR = 10'd4;
localparam ALU_ADD = 10'd0;
localparam ALU_SUB = 10'd256;
localparam ALU_SLT = 10'd2;
localparam ALU_SLTU = 10'd3;
localparam ALU_SLL = 10'd1;
localparam ALU_SRL = 10'd5;
localparam ALU_SRA = 10'd261;
localparam ALU_ELSE = 10'd10;
//MEM WRITE EN
localparam MEM_WRITE_EN = 2'd1;
localparam MEM_WRITE_DIS = 2'd0;
//MEM READ EN
localparam MEM_READ_EN = 2'd1;
localparam MEM_READ_DIS = 2'd0;
//MEM WIDTH LOAD
localparam LOAD_BYTE = 3'd0;
localparam LOAD_HALF_WORD = 3'd1;
localparam LOAD_WORD = 3'd2;
localparam LOAD_DOUBLE_WORD = 3'd3;
localparam ULOAD_BYTE = 3'd4;
localparam ULOAD_HALF_WORD = 3'd5;
localparam ULOAD_WORD = 3'd6;
//MEM WIDTH STORE
localparam STORE_BYTE = 3'd0;
localparam STORE_HALF_WORD = 3'd1;
localparam STORE_WORD = 3'd2;
localparam STORE_DOUBLE_WORD = 3'd3;
//WB SEL
localparam WB_GARBAGE = 3'd3;
localparam WB_ALU = 3'd2;
localparam WB_PC_PLUS_4 = 3'd1;
localparam WB_MEM = 3'd0;
//PC SEL
localparam PC_PLUS_4 = 2'd1;
localparam PC_ALU = 2'd0;


reg [1:0]a_sel; 
reg [1:0]b_sel;
reg [9:0]alu_op;
reg [1:0]mem_read_en;
reg [1:0]mem_write_en;
reg [1:0]reg_write_en;
reg [2:0]wb_sel;
reg [1:0]pc_sel;
reg [2:0]br_cond;
reg [6:0]insType; // For immediate generator
reg [2:0]store_width;
reg [2:0]load_width;


always @(*) begin
    case(inst[6:0]) 
    REGISTER_TYPE:          begin//OPCODE-REGISTER 
    a_sel = A_SEL_RS1;
    b_sel = B_SEL_RS2;
    mem_read_en = MEM_READ_DIS;
    mem_write_en = MEM_WRITE_DIS;
    reg_write_en = REG_WRITE_EN;
    wb_sel = WB_ALU;
    pc_sel = PC_PLUS_4;
    insType = REGISTER_TYPE;

    case({inst[31:25],inst[14:12]}) //Uses funct7,funct3 to determine ALU operation
    ALU_ADD:
    alu_op = ALU_ADD;
    ALU_XOR:
    alu_op = ALU_XOR;
    ALU_SUB:
    alu_op = ALU_SUB;
    ALU_OR:
    alu_op = ALU_OR;
    ALU_AND:
    alu_op = ALU_AND;
    ALU_SLL:
    alu_op = ALU_SLL;
    ALU_SRL:
    alu_op = ALU_SRL;
    ALU_SRA: 
    alu_op = ALU_SRA;
    ALU_SLT:
    alu_op = ALU_SLT;
    ALU_SLTU:
    alu_op = ALU_SLTU;
    default:
    alu_op = ALU_ELSE;
    endcase


    end

    IMMEDIATE_TYPE:        begin  //OPCODE-IMMEDIATE
    a_sel = A_SEL_RS1;
    b_sel = B_SEL_IMM;
    mem_read_en = MEM_READ_DIS;
    mem_write_en = MEM_WRITE_DIS;
    reg_write_en = REG_WRITE_EN;
    wb_sel = WB_ALU;
    pc_sel = PC_PLUS_4;
    insType = IMMEDIATE_TYPE;
    
    case(inst[14:12]) //Uses only funct 3 to determine ALU operation
    3'd0:            //ALU ADD WITHOUT FUNCT7
    alu_op = ALU_ADD; 
    3'd4:           //ALU XOR WITHOUT FUNCT7
    alu_op = ALU_XOR;
    3'd6:           //ALU OR WITHOUT FUNCT7
    alu_op = ALU_OR;
    3'd7:           //ALU AND WITHOUT FUNCT7
    alu_op = ALU_AND;
    default:
    alu_op = ALU_ELSE;
    endcase

    if(alu_op == ALU_ELSE)begin
        case ({inst[31:25],inst[14:12]})   //Uses funct7,funct3 to determine ALU operation
            ALU_SLL://SLLI
            alu_op = ALU_SLL; 
            ALU_SRL://SRLI
            alu_op = ALU_SRL; 
            ALU_SRA://SRAI
            alu_op = ALU_SRA; //SRAI
            default: 
            alu_op = ALU_ELSE;
        endcase
    end

    end
    LOAD_TYPE:       begin   //OPCODE-LOAD
    a_sel = A_SEL_RS1;
    b_sel = B_SEL_IMM;
    alu_op = ALU_ADD;
    mem_read_en = MEM_READ_EN;
    mem_write_en = MEM_WRITE_DIS;
    reg_write_en = REG_WRITE_EN;
    wb_sel = WB_MEM;
    pc_sel = PC_PLUS_4;
    insType = LOAD_TYPE;

    case(inst[14:12]) 
    LOAD_BYTE:
    load_width = LOAD_BYTE;
    LOAD_HALF_WORD:
    load_width = LOAD_HALF_WORD;
    LOAD_WORD:
    load_width = LOAD_WORD;
    LOAD_DOUBLE_WORD:
    load_width = LOAD_DOUBLE_WORD;
    ULOAD_BYTE:
    load_width = ULOAD_BYTE;
    ULOAD_HALF_WORD:
    load_width = ULOAD_HALF_WORD;
    ULOAD_WORD:
    load_width = ULOAD_WORD;
    endcase

    end
    STORE_TYPE:       begin   //OPCODE-STORE
    a_sel = A_SEL_RS1;
    b_sel = B_SEL_IMM;
    alu_op = ALU_ADD; 
    mem_read_en = MEM_READ_DIS;
    mem_write_en = MEM_WRITE_EN;
    reg_write_en = REG_WRITE_DIS;
    wb_sel = WB_GARBAGE; // NONE PUT A GARBAGE VALUE
    pc_sel = PC_PLUS_4;
    insType = STORE_TYPE;
    
    case(inst[14:12]) 
    STORE_BYTE:
    store_width = STORE_BYTE;
    STORE_HALF_WORD:
    store_width = STORE_HALF_WORD;
    STORE_WORD:
    store_width = STORE_WORD;
    STORE_DOUBLE_WORD:
    store_width = STORE_DOUBLE_WORD;
    endcase
    


    end
    BRANCH_TYPE:    begin     //OPCODE-BRANCH
    a_sel = A_SEL_PC;   
    b_sel = B_SEL_IMM;
    alu_op = ALU_ADD;
    mem_read_en = MEM_READ_DIS;
    mem_write_en = MEM_WRITE_DIS;
    reg_write_en = REG_WRITE_DIS;
    wb_sel = WB_GARBAGE; //put GARBAGE value
    pc_sel = 1; //pc+4 or alu dependent on if br cond true or not, so doesn't matter at the moment
    insType = BRANCH_TYPE;


    case (inst[14:12])
    BR_EQ:
    br_cond = BR_EQ;
    BR_NEQ:
    br_cond = BR_NEQ; 
    BR_LT: 
    br_cond = BR_LT;
    BR_GE: 
    br_cond = BR_GE;
    BR_LTU:
    br_cond = BR_LTU;
    BR_GEU:
    br_cond = BR_GEU;
    endcase



    end
    J_TYPE:        begin  //OPCODE-JUMP
    a_sel = A_SEL_PC;
    b_sel = B_SEL_IMM;
    alu_op = ALU_ADD;
    mem_read_en = MEM_READ_DIS;
    mem_write_en = MEM_WRITE_DIS;
    reg_write_en = REG_WRITE_EN;
    wb_sel = WB_PC_PLUS_4; 
    pc_sel = PC_ALU; 
    insType = J_TYPE;

    end
    U_TYPE_LUI:   begin  //OPCODE-LUI
    a_sel = A_SEL_RS1;
    b_sel = B_SEL_IMM;
    mem_read_en = MEM_READ_DIS;
    mem_write_en = MEM_WRITE_DIS;
    reg_write_en = REG_WRITE_EN;
    wb_sel = WB_ALU;
    pc_sel = PC_PLUS_4;
    insType = U_TYPE_LUI;
    alu_op = ALU_ADD;
    
    end      
    U_TYPE_AUIPC:     begin     //OPCODE-AUIPC
    a_sel = A_SEL_PC;
    b_sel = B_SEL_IMM;
    mem_read_en = MEM_READ_DIS;
    mem_write_en = MEM_WRITE_DIS;
    reg_write_en = REG_WRITE_EN;
    wb_sel = WB_ALU;
    pc_sel = PC_PLUS_4;
    insType = U_TYPE_AUIPC;
    alu_op = ALU_ADD;
    end 
    endcase 
end

assign wInstype = insType;
assign wA_sel = a_sel;
assign wB_sel = b_sel;
assign wAlu_op = alu_op;
assign wMem_read_en = mem_read_en;
assign wMem_write_en = mem_write_en;
assign wReg_write_en = reg_write_en;
assign wWb_sel = wb_sel;
assign wPc_sel = pc_sel;
assign wBr_cond = br_cond;
assign wStore_width = store_width;
assign wLoad_width = load_width;


endmodule

