RISC-V CPU Single Cycle



Please change the assembly instructions in t.asm or add your own assembly file. After assemble it into machine code and then dump it into projmem.hex using this instruction below.
java -jar rars.jar nc mc CompactTextAtZero t.asm > projmem.hex
If you are using another assembly file change t.asm in the instruction above to your files name.


To run the program please run these instructions consectively in terminal.

iverilog -g2012 -c sources1.txt -o cpu
vvp cpu
