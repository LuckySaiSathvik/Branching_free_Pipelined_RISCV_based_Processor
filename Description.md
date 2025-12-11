**Branching_free_Pipelined_RISCV_based_Processor**

This project is on designing 16-bit 5-staged pipelined RISC-V based Processor, with 0.5kB data and instruction memories each separately [Harvard Architecture] along with 16 general-purpose registers. The processor (with memory elements) is coded in Verilog HDL along with Python script that converts Assembly code into binary, based on the Instruction Set Architecture (ISA) which contains 14 unique instructions to perform logical, shift, arithmetic operations as well as data movement between reg-to-reg, reg-to-mem & mem-to-reg respectively; the NOP instruction was used as manual resolver to mitigate pipeline hazards.

My contribution involved individually designing the ISA, complete processor design and the assembler script; with the design implemented on Altera DE10 FPGA with syntax-error-free simulation (on Quartus Prime) and output displayed on the seven-segment displays (clock was based on user-input and not in-built). More details on the ISA, results and some additional information can be found in the report attached to the repository; and if there are any changes possible for better results those can be mailed to (please check profile for contact details).

**Steps to generate the Binary equivalent of the instructions in the device after cloning:**
(these steps are for Linux terminal with python3 installed; if the IDE being used supports file handling, then similar steps can be followed)

1) Edit "1_assembly_program.asm" based on the intended implementation (refer to the ISA in the report and default code to make changes; the default code has all instructions in it so it is recommended to go ahead without any changes).
2) Now run: **python3 2_code_assembler.py**, and wait till it says: "Machine code written to 3_instr_memory_values.mif"; if anything other than this is seen then recheck the assembly code, since python script can sense Assembly code Errors. Also make sure there are atleast 3 NOPs inserted after load operations, since this is the only way to mitigate RAW-based hazards in this processor (refer to the report and default code for better understanding of these insertions).
3) After generating the "3_instr_memory_values.mif" file, replace that in the original cloned directory where the project files are present.

**Steps to simulate and implement on the FPGA after generating Binary equivalent of the instructions:**
(these steps are for Quartus Prime 24.1std on Windows 11 and can be tried on other versions and/or softwares similarly)

1) Open Quartus Prime and create a new project named "fpga_mapping" as the top module with the desired FPGA board; then add all the files (the mif file newly generated) into the project; before clicking Finish check if all the files have been uploaded.
2) In: Settings -> Simulation -> Compile Testbench -> New, set the testbench module name as "fpga_mapping_tb" and attach the 7_b_fpga_mapping_tb.v file to it.
3) Click Processing -> Start Compilation to start compiling and ignore the warnings; if there are errors then the assembly code written must have had problems so recheck, then regenerate and reupload the memory file into the project (the mif file can't be viewed in Quartus Prime, so better go back to the generation steps to do it).
4) After this, go to: Tools -> Run Simulation Tool -> RTL Simulation to check the simulation waveform and how data will be displayed on the seven segments and LEDs.
5) Provide the particular pin assignment in; Assignments -> Pin Planner based on the FPGA under use (in the report, check the table for the DE10 FPGA pin mappings); for clock provide pushbutton input (recommended), for reset and data_show use switch inputs; to display the 1-bit flags and data retain symbols use LEDs and finally the seven segments are used to display the program counter (2 segments) and instruction/result (4 segments). Refer to the report for which outputs pins are recommended to be assigned.
6) Finally go to Tools -> Programmer and select the FPGA connected (after turning ON board); after this go to Add Device -> select SoC series V in device family and SOCVHPS; then start the implementation and observe the outputs on the LEDs and seven-segments using switches and the pushbutton.

**Note:** Please don't change any other files after cloning this repository other than 1_assembly_program.asm & the generated 3_instr_memory_values.mif for the best results. You can learn more from the report attached and are free to suggest changes (provide improved results if arrived to and contact me).

**Sai Sathvik G B**
Contributor
