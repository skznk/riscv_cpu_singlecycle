64-bit RISC-V CPU Single Cycle CPU

Project idea and creation based on the information/notes learned about the RISC-V single cycle CPU in CS211 in Professor Patels Spring 2025 class. I enjoyed the material a lot and wanted to make a project based on that. The CPU uses a Kogge-Stone adder and aside from that everything is largely based on my notes from the class.

Please change the assembly instructions in t.asm or add your own assembly file. After assemble it into machine code and then dump it into projmem.hex using this instruction below. 

java -jar rars.jar nc a tests/branch.asm dump .text HexText projmem.hex
projmem.hex is little endian so please edit the dump to two bytes per line.

If you are using another assembly file change branch.asm in the instruction above to your relative path or absolute path.

After dumping to projmem.hex run these instructions consectively in the terminal.

iverilog -g2012 -c sources1.txt -o cpu 
vvp cpu

CPU instructions and results are printed into the terminal.

Here is a video of me demonstrating my code!

