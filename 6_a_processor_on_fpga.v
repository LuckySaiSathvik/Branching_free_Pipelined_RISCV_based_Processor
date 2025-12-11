//combined datapath and controller of processor
module processor_on_fpga(
	input clock,                                    //processor clock
	input reset,                                    //processor reset
	output instr_stop,                              //extraction stop signal
	//IF stage outputs
	output [7:0]now_program_counter,                //current program counter
	output [15:0]current_instruction,               //current instruction
	output [3:0]now_opcode,                         //current opcode
	//ID stage outputs
	output [3:0]reg_read1_addr,                     //port 1 register file address to be read
	output [3:0]reg_read2_addr,                     //port 2 register file data that is read
	output [15:0]reg_read1_data,                    //port 1 register file address to be read
	output [15:0]reg_read2_data,                    //port 2 register file data that is read
	output [7:0]mem_read_address,                   //data memory address to be read
	output [15:0]mem_read_data,                     //data memory value that is read
	//EX stage outputs
	output [3:0]current_operation,                  //current ALU operation
	output [15:0]alu_in_1,                          //first operand into ALU
	output [15:0]alu_in_2,                          //second operand into ALU
	output [15:0]alu_out,                           //result from the ALU
	output zero_flag,                               //zero flag; triggers if resultant=0
	output negative_flag,                           //negative flag; triggers if resultant<0
	output error_flag,                              //error flag; triggers if resultant=x
	//MEM stage outputs
	output mem_write,                               //data memory write signal
	output [7:0]mem_write_address,                  //data memory address where to be written
	output [15:0]mem_write_data,                    //data memory value what to be written
	output mem_data_retained,                       //data memory update signal
	//WB stage outputs
	output reg_write,                               //register file write signal
	output [3:0]reg_write_address,                  //register file address to be written
	output [15:0]reg_write_data,                    //register file data that is written
	output reg_data_retained                        //register file update signal
	
);
	wire reg_signal_write, mem_signal_write;
	
	//instantiating the datapath
	datapath DATA(
			.clock(clock),
			.reset(reset),
			.reg_signal_write(reg_signal_write),
			.mem_signal_write(mem_signal_write),
			.instr_stop(instr_stop),
			//IF stage
			.now_program_counter(now_program_counter),
			.current_instruction(current_instruction),
			.now_opcode(now_opcode),
			//ID stage
			.reg_read1_addr(reg_read1_addr),
			.reg_read2_addr(reg_read2_addr),
			.reg_read1_data(reg_read1_data),
			.reg_read2_data(reg_read2_data),
			.mem_read_address(mem_read_address),
			.mem_read_data(mem_read_data),
			//EX stage
			.current_operation(current_operation),
			.alu_in_1(alu_in_1),
			.alu_in_2(alu_in_2),
			.alu_out(alu_out),
			.zero_flag(zero_flag),
			.negative_flag(negative_flag),
			.error_flag(error_flag),
			//MEM stage
			.mem_write(mem_write),
			.mem_write_address(mem_write_address),
			.mem_write_data(mem_write_data),
			.mem_data_retained(mem_data_retained),
			//WB stage
			.reg_write(reg_write),
			.reg_write_address(reg_write_address),
			.reg_write_data(reg_write_data),
			.reg_data_retained(reg_data_retained)
	);
	
	//instantiating the controller
	controller CONTROL(.opcode(now_opcode),
						.reg_signal_write(reg_signal_write),
						.mem_signal_write(mem_signal_write)
	);
endmodule
