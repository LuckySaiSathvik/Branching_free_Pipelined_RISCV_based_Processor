//module that maps fpga pins to the processor
module fpga_mapping(
	input clock,                               //processor clock
	input reset,                               //processor reset
	input data_show,                           //flip switch to show instruction or data processed
	//multi bit outputs
	output [7:0]program_counter,               //program counter value
	output [15:0]show_this,                    //result on seven segment display
	output [15:0]instruction,                  //instruction being processed
	output [15:0]data_result,                  //data being processed
	//flags and signals shown
	output instr_stop_show,                    //instruction stop signal
	output zero_flag_show,                     //zero flag
	output negative_flag_show,                 //negative flag
	output error_flag_show,                    //error flag
	output mem_data_retained_show,             //data retained in data memory
	output reg_data_retained_show,             //data retained in register file
	//six seven segment displays
	output [0:6]seven_seg_5,
	output [0:6]seven_seg_4,
	output [0:6]seven_seg_3,
	output [0:6]seven_seg_2,
	output [0:6]seven_seg_1,
	output [0:6]seven_seg_0
);
	wire proc_clock;                              //slower clock sent into the processor
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
	
	//instantiating the clock divider module
	//clock_divider CLK_DIV(.clock_in(clock),.clock_out(proc_clock));
	
	//instantiating the processor module
	processor_on_fpga IMPLEMENT (.clock(clock),
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
	
	//assign the results from processor directly
	assign instruction = current_instruction;      //check the value of the instruction
	assign data_result = reg_write_data;           //check the value of data being processed
	assign program_counter = now_program_counter;  //check the value of program counter
	
	assign instr_stop_show = instr_stop;           //check the value of instruction stop signal
	assign zero_flag_show = zero_flag;             //check the value of zero flag
	assign negative_flag_show = negative_flag;     //check the value of negative flag
	assign error_flag_show = error_flag;           //check the value of error flag
	assign reg_data_retained_show = reg_data_retained;  //check if data retained in register file
	assign mem_data_retained_show = mem_data_retained;  //check if data retained in data memory
	
	wire [15:0]display;                             //this will be on display
	reg [15:0]delay_1, delay_2,delay_3,delay_4,delay_5,delay_6;     //shift registers used to add delay
	reg [15:0]final_instruction,final_result,final_program_counter;//these will be pushed into 7 segment display
	
	always@(posedge clock)
		begin
			//push the instruction by four clock cycles
			delay_1 <= current_instruction;
			delay_2 <= delay_1;
			delay_3 <= delay_2;
			final_instruction <= delay_3;
			//push the program counter by four clock cycles
			delay_4 <= now_program_counter;
			delay_5 <= delay_4;
			delay_6 <= delay_5;
			final_program_counter <= delay_6;
			//push the data processed by zero clock cycles
			final_result <= reg_write_data;
		end
	
	//push the value based on switch
	assign display = (data_show == 1'b0) ? final_instruction : final_result;
	assign show_this = display;
	
	//instantiating the seven segment decoder modules
	segment_decoder SEG5(.value(display[15:12]),.segment(seven_seg_5));
	segment_decoder SEG4(.value(display[11:8]),.segment(seven_seg_4));
	segment_decoder SEG3(.value(display[7:4]),.segment(seven_seg_3));
	segment_decoder SEG2(.value(display[3:0]),.segment(seven_seg_2));
	segment_decoder SEG1(.value(final_program_counter[7:4]),.segment(seven_seg_1));
	segment_decoder SEG0(.value(final_program_counter[3:0]),.segment(seven_seg_0));
endmodule
