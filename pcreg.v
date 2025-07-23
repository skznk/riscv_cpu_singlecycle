// PC REGISTER 
module pcREG(input clk, input wr_en, input reset, input [63:0]next_pc, output reg [63:0]cur_pc ); //Not currently implementing wr_en, going to do hazard relating things after taking computer architechture 2r

always @(posedge clk or posedge reset) begin
    
    if (reset)
    cur_pc <= 0;
    else begin
    cur_pc <= next_pc;    
    end

end

endmodule

