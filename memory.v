
module mems(input clk, input[63:0]addr, input [2:0] storeSize, input [2:0]loadSize, input readEn, input writeEn, input [63:0]wr_data, input [63:0]rs1, input [63:0]rs2,  output reg [31:0]inst, output reg [63:0]rd_data);

localparam load_byte = 3'd0;
localparam load_half = 3'd1;
localparam load_word = 3'd2;
localparam load_double = 3'd3;
localparam uload_byte = 3'd4;
localparam uload_half = 3'd5;
localparam uload_word = 3'd6;
localparam uload_double = 3'd7;

localparam store_byte = 3'd0;
localparam store_half = 3'd1;
localparam store_word = 3'd2;
localparam store_double = 3'd3;

reg [7:0] mem[0:511]; //Memory array (instructions) - Referred to as Instruction array
reg [7:0] data[0:511]; //Memory array (data) - Referred to as data array

initial begin //Loads instruction hex from projmem.hex into the memory array. Change projmem.hex to whatever hex you want to load in or dump the hexes into projmem.hex.
    $readmemh("projmem.hex",mem);
end

wire signed [63:0]immload = inst[31:20]; //Immediate offset used in load
wire signed [63:0]immstore = inst[31:25]; //Immediate offset used in store


always @(*) begin //loads instruction from instruction array 
inst = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
end


always@(*)begin //Processes any load instructions
    if (readEn && rs1 >= 64'd0 && rs1 <= 64'd128) begin
        case (loadSize)
            load_byte: rd_data = {{56{data[rs1+immload][7]}}, data[rs1+immload]};
            load_half: rd_data = {{48{data[rs1+immload+1][7]}}, data[rs1+immload+1], data[rs1+immload]}; 
            load_word: rd_data = {{32{data[rs1+immload+3][7]}}, data[rs1+immload+3], data[rs1+immload+2], data[rs1+immload+1], data[rs1+immload]}; 
            load_double: rd_data = {data[rs1+immload+7], data[rs1+immload+6], data[rs1+immload+5], data[rs1+immload+4], data[rs1+immload+3], data[rs1+immload+2], data[rs1+immload+1], data[rs1+immload]}; 
            uload_byte: rd_data = {56'd0, data[rs1+immload]}; 
            uload_half: rd_data = {48'd0, data[rs1+immload+1], data[rs1+immload]}; 
            uload_word: rd_data = {32'd0, data[rs1+immload+3], data[rs1+immload+2], data[rs1+immload+1], data[rs1+immload]}; 
            default: rd_data = 64'd0;
        endcase
    end else begin
        rd_data = 64'd0;
    end


end

always @(posedge clk)begin //Processes any store instructions
    
    if(writeEn && rs1 >= 64'd0 && rs1<= 64'd128) begin 
        case (storeSize)
        3'd0: begin//STORE_BYTE
        data[rs1+immstore] = rs2[7:0];
        end
        3'd1: begin//STORE_HALF_WORD
        data[rs1+immstore] = rs2[7:0];
        data[rs1+immstore+1] = rs2[15:8]; 
        end
        3'd2: begin //STORE_WORD
        data[rs1+immstore] = rs2[7:0];
        data[rs1+immstore+1] = rs2[15:8];   
        data[rs1+immstore+2] = rs2[23:16];
        data[rs1+immstore+3] = rs2[31:24];   
        end    
        3'd3: begin//STORE_DOUBLE_WORD
        data[rs1+immstore-128] = rs2[7:0];
        data[rs1+immstore+1-128] = rs2[15:8];   
        data[rs1+immstore+2-128] = rs2[23:16];
        data[rs1+immstore+3-128] = rs2[31:24];  
        data[rs1+immstore+4-128] = rs2[39:32];
        data[rs1+immstore+5-128] = rs2[47:40];   
        data[rs1+immstore+6-128] = rs2[55:48];
        data[rs1+immstore+7-128] = rs2[63:56];         
        end   
        endcase

    end
end

endmodule




