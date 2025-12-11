//processor testbench
module processor_on_fpga_tb;
	//inputs are reg datatype
	reg clock;                                    //processor clock
	reg reset;                                    //processor reset
	integer i;                                    //for loop variable
	//outputs are wire datatype
	//IF stage
	wire instr_stop;                              //program counter stop signal
	wire [7:0]now_program_counter;                //current program counter
	wire [15:0]current_instruction;               //current instruction
	wire [3:0]now_opcode;                         //current opcode
	//ID stage
	wire [3:0]reg_read1_addr;                     //port 1 register file address to be read
	wire [3:0]reg_read2_addr;                     //port 2 register file data that is read
	wire [15:0]reg_read1_data;                    //port 1 register file address to be read
	wire [15:0]reg_read2_data;                    //port 2 register file data that is read
	wire [7:0]mem_read_address;                   //data memory address to be read
	wire [15:0]mem_read_data;                     //data memory value that is read
	//EX stage
	wire [3:0]current_operation;                  //current ALU operation
	wire [15:0]alu_in_1;                          //first operand into ALU
	wire [15:0]alu_in_2;                          //second operand into ALU
	wire [15:0]alu_out;                           //result from the ALU
	wire zero_flag;                               //zero flag; triggers if resultant=0
	wire negative_flag;                           //negative flag; triggers if resultant<0
	wire error_flag;                              //error flag; triggers if resulant=x
	//MEM stage
	wire mem_write;                               //data memory write signal
	wire [7:0]mem_write_address;                  //data memory address where to be written
	wire [15:0]mem_write_data;                    //data memory value what to be written
	wire mem_data_retained;                       //data memory update signal
	//WB stage
	wire reg_write;                               //register file write signal
	wire [3:0]reg_write_address;                  //register file address to be written
	wire [15:0]reg_write_data;                    //register file data that is written
	wire reg_data_retained;                       //register file update signal
	
	//instantiate the processor RTL design
	processor_on_fpga SIMULATION (.clock(clock),
							.reset(reset),
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
	
	//clock generation
	initial
		begin
			clock = 1'b1;
			reset = 1'b0;
		end
	//10ns clock time period
	always #5 clock = ~clock;
	
	//reset generation
	//task-based reset used
	task reset_perform();
		begin
			@(negedge clock)
				reset = 1'b1;
			@(negedge clock)
				reset = 1'b0;
		end
	endtask
	
	//testbench logic
	//reset, then load instructions from the binary file and finish after a while
	initial
		begin
			reset_perform();
			#1000 $finish;
		end
endmodule
