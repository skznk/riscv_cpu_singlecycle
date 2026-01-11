# loop test

addi x1, x0, 5     
addi x2, x0, 0    

loop:               # If x1 != 0, jump back to 'loop'
addi x2, x2, 1      # loop continues until x1 reaches 0
addi x1, x1, -1
bne  x1, x0, loop  
                  
