# t.asm
 
        # Test LUI
    lui x1, 0x12345         # x1 = 0x12345000

    # Test AUIPC
    auipc x2, 0x1           # x2 = PC + (0x1 << 12)
    
    # Observe values
    addi x3, x1, 0          # x3 = copy of x1
    addi x4, x2, 0          # x4 = copy of x2

