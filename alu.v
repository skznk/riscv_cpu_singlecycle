// ALU COMPONENT

module alu(input signed [63:0]a, input signed [63:0]b, input [3:0]alu_op, output reg [63:0]alu_result);

//Different ALU operations
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

wire signed [63:0]add;  //Used as the koggestone addition output
wire signed [63:0]sub;  //Used as the koggestone subtraction output
reg addEN = 0; //Used to see if we need addition/subtraction for the instruction


KoggeStone aluKOGGADD(a,b,add);
KoggeStone aluKOGGSUB(a,(~b+1),sub);


always@(*) begin   //Determining the alu operation and its corresponding result 
    case (alu_op)
        ALU_AND:
        alu_result = a & b;
        ALU_OR:
        alu_result = a | b;
        ALU_XOR:
        alu_result = a ^ b;
        ALU_ADD: begin
        addEN = 1;
        alu_result = add;
        end
        ALU_SUB: begin
        addEN = 1;
        alu_result = sub;
        end
        ALU_SLT:
        alu_result = ($signed(a)<$signed(b)) ? 1:0;
        ALU_SLTU:
        alu_result = (a<b) ? 1:0;
        ALU_SLL:
        alu_result = a<<b;
        ALU_SRL:
        alu_result = a>>b;
        ALU_SRA:
        alu_result = a>>>b;
        default: 
        alu_result = 0;

    endcase
end

endmodule


module Amux(input [63:0]pc, input [63:0]rs1, input a_sel, output [63:0]out1); //A mux

assign out1 = (a_sel) ? pc:rs1;

endmodule

module Bmux(input [63:0]rs2, input [63:0]imm, input b_sel, output [63:0]out1); //B mux

assign out1 = (b_sel) ? rs2:imm;

endmodule

module brCMP(input [63:0]rs1, input [2:0]br_cond, input [63:0]rs2, output br_taken); //Branch comparison 

//Branch conditionals
localparam BR_EQ = 3'd0;
localparam BR_NEQ = 3'd1;
localparam BR_LT = 3'd4;
localparam BR_GE = 3'd5;
localparam BR_LTU = 3'd6;
localparam BR_GEU = 3'd7;

reg take; 
reg [63:0] inrs1;
reg [63:0] inrs2;


always@(*) begin //Determines the conditional and evaluates
    case (br_cond) 
    BR_EQ:
    take = (rs1==rs2) ? 1:0;
    BR_NEQ: 
    take = (rs1==rs2) ? 0:1;
    BR_LT: 
    take = (rs1 < rs2) ? 1:0;
    BR_GE: 
    take = (rs1 >= rs2) ? 1:0;
    BR_LTU: 
    take = (rs1<rs2) ? 1:0;
    BR_GEU:
    take = (rs1>=rs2) ? 1:0;
    default:
    take = 0;
    endcase 
end

assign br_taken = take; // Determines if we take the conditional or not

endmodule 

module KoggeStone(input [63:0]a, input [63:0] b, output [63:0]fin); // Our famous KoggeeStone adder, was kind of annoying to figure out. Once I learned how it works it was pretty cool honestly. Koggestone basically likes reaching back bits to progressively to determine the addition.

wire [63:0]p,g;
wire [63:0]p1,g1;
wire [63:0]p2,g2;
wire [63:0]p3,g3;
wire [63:0]p4,g4;
wire [63:0]p5,g5;
wire [63:0]p6,g6;


genvar i;

generate

for(i = 0; i<64; i=i+1) begin    //Stage 0
assign g[i] = a[i]&b[i];
assign p[i] = a[i]^b[i];
end

endgenerate


   assign p1[0] = p[0];
   assign g1[0] = g[0];
   
generate
   for(i = 1; i<64; i = i+1) begin  //Stage 1
    assign p1[i] = p[i] & p[i-1];
    assign g1[i] = (p[i] & g[i-1]) | g[i];
   end                                        
   
endgenerate

    
        generate
            for(i = 0; i<2; i = i+1) begin  //Stage 2
                assign p2[i] = p1[i];
                assign g2[i] = g1[i];
             end   
        endgenerate
        
        generate
            for(i = 2; i<64; i = i+1)begin  //Stage 2
            assign p2[i] = p1[i] & p1[i-2];
            assign g2[i] = (p1[i] & g1[i-2]) | g1[i];
            end              

        endgenerate

           
            generate
                
                for(i = 0; i<4; i = i+1)begin  //Stage 3
                        assign p3[i] = p2[i];
                        assign g3[i] = g2[i];
                    end   
            endgenerate

            generate

                for(i = 4; i<64; i = i+1)begin  //Stage 3
                    assign p3[i] = p2[i] & p2[i-4];
                    assign g3[i] = (p2[i] & g2[i-4]) | g2[i];
                    end              

            endgenerate

               
                generate
                
                    for(i = 0; i<8; i = i+1)begin  //Stage 4
                        assign p4[i] = p3[i];
                        assign g4[i] = g3[i];
                    end    
                endgenerate

                generate

                    for(i = 8; i<64; i = i+1)begin  //Stage 4
                        assign p4[i] = p3[i] & p3[i-8];
                        assign g4[i] = (p3[i] & g3[i-8]) | g3[i];
                        end              

                endgenerate

                    
                    generate
                        
                        for(i = 0; i<16; i = i+1)begin  //Stage 5
                            assign p5[i] = p4[i];
                            assign g5[i] = g4[i];
                        end    
                    endgenerate
                    
                    generate
                        for(i = 16; i<64; i = i+1)begin  //Stage 5
                            assign p5[i] = p4[i] & p4[i-16];
                            assign g5[i] = (p4[i] & g4[i-16]) | g4[i];
                            end              

                    endgenerate

                      
                        generate
                            for(i = 0; i<32; i = i+1)begin  //Stage 6
                                    assign p6[i] = p5[i];
                                    assign g6[i] = g5[i];
                                end    
                        endgenerate
                        
                        generate
                            for(i = 32; i<64; i = i+1)begin  //Stage 6
                                assign p6[i] = p5[i] & p5[i-32];
                                assign g6[i] = (p5[i] & g5[i-32]) | g5[i];
                                end              

                        endgenerate

assign fin[0] = p[0];
generate                   
for(i = 1; i<64; i = i+1)begin
assign fin[i] = p[i] ^ g6[i-1];
end
endgenerate


endmodule


