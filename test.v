`timescale 1ns / 1ps

module test; //Used this for module testing, irrelevant to the finished version.

  reg clk = 0;
  reg reset = 1;

  // clock generator
  always #5 clk = ~clk;

  top_mod uut (
    .clock(clk),
    .reset(reset)
  );

  initial begin
    $dumpfile("cpu.vcd");
    $dumpvars(0, uut);

    #10 reset = 0;  // release reset after 10ns

    #200; 

    $display("Register x1 = %d", uut.rs1);
    $display("Register x2 = %d", uut.rs2);
    $display("Memory[0]  = %d", uut.rd);  
    $finish;
  end

endmodule
