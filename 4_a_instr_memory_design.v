//instruction memory of processor
module instr_memory(
	input [7:0]program_counter,                           //program counter
	output instr_stop,                                    //signal to stop processor work
	output [15:0]instruction                              //instruction
);
	reg [15:0]instruction_memory[0:255];                  //instruction memory of 256 words each of 16 bits
	
	initial
		begin
			$readmemb("3_instr_memory_values.mif",instruction_memory);//load the instructions from file
		end
	//instruction assignment
	assign instruction = (instr_stop == 1'b0) ? instruction_memory[program_counter] : 16'dx;
	//no next instruction exists
	assign instr_stop = (instruction_memory[program_counter + 8'd1] === 16'dx);
endmodule