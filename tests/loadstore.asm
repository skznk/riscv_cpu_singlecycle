#Load and store test
addi x1, x0, 0     
addi x2, x0, 42    

sw   x2, 0(x1)     # mem[0] = 42
lw   x3, 0(x1)     # x3 = 42
