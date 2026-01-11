#Branch test

addi x1, x0, 5
addi x2, x0, 5

beq  x1, x2, equal
addi x3, x0, 0     # should skip

equal:
addi x3, x0, 1     # x3 = 1