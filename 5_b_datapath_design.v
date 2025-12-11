//datapath of processor
module datapath(
	input clock,                                    //processor clock
	input reset,                                    //processor reset
	input reg_signal_write,                         //write signal for register file
	input mem_signal_write,                         //write signal for data memory
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
	output [7:0]mem_read_address,                   //data memory address where to be read
	output [15:0]mem_read_data,                     //data memory value that is read
	//EX stage outputs
	output [3:0]current_operation,                  //current ALU operation
	output [15:0]alu_in_1,                          //first operand into ALU
	output [15:0]alu_in_2,                          //second operand into ALU
	output [15:0]alu_out,                           //result from the ALU
	output zero_flag,                               //zero flag; triggers if resultant=0
	output negative_flag,                           //negative flag; triggers if resultant<0
	output error_flag,                              //error flag; triggers if resulant=x
	//MEM stage outputs
	output mem_write,                               //data memory write signal
	output [7:0]mem_write_address,                  //data memory address where to be written
	output [15:0]mem_write_data,                    //data memory value what to be written
	output mem_data_retained,                       //detects updates in data memory
	//WB stage outputs
	output reg_write,                               //register file write signal
	output [3:0]reg_write_address,                  //register file address to be written
	output [15:0]reg_write_data,                    //register file data that is written
	output reg_data_retained                        //detects updates in register file
);
	//classification of instructions
	localparam mem_data_inst = 3'b000,              //ldm,stm
		  reg_data_inst = 3'b001,                    //ldr,mov
		  andor_inst = 3'b010,                       //and,or
		  notxor_inst = 3'b011,                      //not,xor
		  shift_inst = 3'b100,                       //shl,shr
		  addsub_inst = 3'b101,                      //add,sub
		  div_inst = 3'b110,                         //div
		  nop = 3'b111;                              //no operation
	
	//classification of operations
	localparam bit_and = 4'b0000,                   //and
		  bit_or = 4'b0001,                          //or
		  bit_xor = 4'b0010,                         //xor
		  bit_not = 4'b0011,                         //not
		  shift_log_left = 4'b0100,                  //logic shift left
		  shift_ari_left = 4'b0101,                  //arith shift left
		  shift_log_right = 4'b0110,                 //logic shift right
		  shift_ari_right = 4'b0111,                 //arith shift right
		  arith_add = 4'b1000,                       //add
		  arith_sub = 4'b1001,                       //sub
		  arith_div = 4'b1010;                       //div
	
	//data memory read-write ports
	reg [7:0]mem_addr_read;                         //read memory address
	wire [15:0]mem_data_read;                       //memory read data
	reg [7:0]mem_addr_write;                        //write memory address
	reg [15:0]mem_data_write;                       //memory write data
	
	//register file read-write ports
	reg [3:0]reg_addr_read1;                        //1st read address
	reg [3:0]reg_addr_read2;                        //2nd read address
	wire [15:0]reg_data_read1;                      //1st read data
	wire [15:0]reg_data_read2;                      //2nd read data
	reg [3:0]reg_addr_write;                        //write address
	reg [15:0]reg_data_write;                       //write data
	
	//instruction memory ports
	reg [7:0]program_counter;                       //program counter
	wire [15:0]instruction;                         //instruction extracted
	
	//arithmetic and logical unit (alu) ports
	reg [3:0]operation;                             //alu operation
	reg [15:0]alu_op1;                              //alu 1st operand
	reg [15:0]alu_op2;                              //alu 2nd operand
	wire [15:0]alu_res;                             //alu result
	
	/*stages of pipelining implememted are:
	IF = instruction fetch
	ID = instruction decode
	EX = execute operation
	MEM = memory access
	WB = write back registers*/
	
	//pipelining registers between IF and ID stages
	reg [7:0]IF_ID_program_counter;
	reg [3:0]IF_ID_opcode;
	reg [15:0]IF_ID_instruction;
	
	//pipelining registers between ID and EX stages
	reg [3:0]ID_EX_opcode;
	reg [15:0]ID_EX_instruction;
	reg [3:0]ID_EX_reg_addr_read1;
	reg [3:0]ID_EX_reg_addr_read2;
	reg [15:0]ID_EX_reg_data_read1;
	reg [15:0]ID_EX_reg_data_read2;
	reg [7:0]ID_EX_mem_addr_read;
	reg [15:0]ID_EX_mem_data_read;
	reg ID_EX_reg_signal_write;
	reg [3:0]ID_EX_reg_addr_write;
	reg [15:0]ID_EX_reg_data_write;
	reg ID_EX_mem_signal_write;
	reg [7:0]ID_EX_mem_addr_write;
	reg [15:0]ID_EX_mem_data_write;
	reg [3:0]ID_EX_operation;
	
	//pipelining registers between EX and MEM stages
	reg [3:0]EX_MEM_operation;
	reg [15:0]EX_MEM_alu_res;
	reg EX_MEM_mem_signal_write;
	reg [7:0]EX_MEM_mem_addr_write;
	reg [15:0]EX_MEM_mem_data_write;
	reg EX_MEM_reg_signal_write;
	reg [3:0]EX_MEM_reg_addr_write;
	reg [15:0]EX_MEM_reg_data_write;
	
	//pipelining registers between MEM and WB stages
	reg MEM_WB_reg_signal_write;
	reg [3:0]MEM_WB_reg_addr_write;
	reg [15:0]MEM_WB_reg_data_write;
	
	//nop operation related variables
	wire [3:0]count_ID;                             //ID stage NOP counter
	wire [3:0]count_EX;                             //EX stage NOP counter
	reg counter_ID_en;                              //enable signal for ID counter
	reg counter_EX_en;                              //enable signal for EX counter
	
	//instruction fetch stage
	always@(posedge clock)                          //sequential logic for extracting instructions
		begin
			if(reset)                                 //synchronous reset; and if high
				program_counter <= 8'd0;               //initialise program counter
			else if(instr_stop == 1'b1)
				program_counter <= 8'dx;               //stop incrementing
			else
				//continue incrementing
				program_counter <= program_counter + 8'd1;
		end
	
	//instantiating instruction memory
	instr_memory IM(
			.program_counter(program_counter),
			.instr_stop(instr_stop),
			.instruction(instruction)
	);
	
	//intermediate between IF and ID stages
	always @(posedge clock)                       //sequential logic for moving these into registers
		begin
			IF_ID_program_counter <= program_counter;
			IF_ID_instruction <= instruction;
			IF_ID_opcode <= instruction[15:12];
		end
	
	//assigining to show what's going on in instruction memory
	assign now_program_counter = IF_ID_program_counter;
	assign current_instruction = IF_ID_instruction;
	assign now_opcode = IF_ID_opcode;
	
	//instruction decode stage
	always@(*)                                        //combinational logic to decode data from instruction
		begin
			case(IF_ID_opcode[3:1])                     //consider the instruction classification
				mem_data_inst: begin                                    //includes ldm and stm					
					if(IF_ID_opcode[0] == 1'b0)                          //if ldm
						begin
							reg_addr_write = IF_ID_instruction[11:8];      //write to reg
							mem_addr_read = IF_ID_instruction[7:0];        //address allocation
							reg_data_write = mem_data_read;                //write this from mem

						end
					else                                                 //if stm
						begin
							reg_addr_read1 = IF_ID_instruction[11:8];      //read from reg
							mem_addr_write = IF_ID_instruction[7:0];       //address allocation
							mem_data_write = reg_data_read1;               //write this to mem
						end
					end
				
				reg_data_inst: begin                                    //includes ldr and mov
					reg_addr_write = IF_ID_instruction[11:8];            //write to this register
					if(IF_ID_opcode[0] == 1'b0)                          //if ldr
						begin
							reg_data_write = {8'b0,IF_ID_instruction[7:0]};//assigning immediate from instruction
						end
					else                                                 //if mov
						begin
							reg_addr_read1 = IF_ID_instruction[7:4];       //read from reg
							reg_data_write = reg_data_read1;               //write this from reg
						end
					end
				
				andor_inst, addsub_inst: begin                           //includes and,or,add,sub
					reg_addr_read1 = IF_ID_instruction[7:4];              //read from this register
					reg_addr_read2 = IF_ID_instruction[3:0];              //read from this register too
					reg_addr_write = IF_ID_instruction[11:8];             //write to this register
					if(IF_ID_opcode[3:1]==andor_inst)                     //operation is and or or
						operation = (IF_ID_opcode[0] == 1'b0)? bit_and : bit_or;
					else if(IF_ID_opcode[3:1]==addsub_inst)               //operation is add or sub
						operation = (IF_ID_opcode[0] == 1'b0)? arith_add : arith_sub;
					else
						operation = 4'bxxxx;                               //unknown operation
					end
				
				notxor_inst, div_inst: begin                             //includes not,xor,div
					reg_addr_write = IF_ID_instruction[11:8];             //write to this register
					reg_addr_read1 = IF_ID_instruction[7:4];              //read from this register
					if(IF_ID_opcode[0] == 1'b0)                           //if xor or div
						begin
							reg_addr_read2 = IF_ID_instruction[3:0];		   //read from this register too
							if(IF_ID_opcode[3:1]==notxor_inst)
								operation = bit_xor;                         //operation is xor
							else if(IF_ID_opcode[3:1]==div_inst)
								operation = arith_div;                       //operation is div
							else
								operation = 4'bxxxx;                         //unknown operation 
						end
					//if not instruction
					else if((IF_ID_opcode[3:1]==notxor_inst)&&(IF_ID_opcode[0] == 1'b1))
						operation = bit_not;                                //operation is not
					else
						operation = 4'bxxxx;                                //unknown operation
					end
				
				shift_inst: begin                                         //includes shl and shr
					reg_addr_write = IF_ID_instruction[11:8];              //write to this register
					reg_addr_read1 = IF_ID_instruction[7:4];               //read from this register
					if(IF_ID_instruction[3]==2'b0)                         //logical shift
						begin
							if(IF_ID_opcode[0] == 1'b0)
								operation = shift_log_left;                   //logic shift left
							else
								operation = shift_log_right;                  //logic shift right
						end
					else if(IF_ID_instruction[3]==2'b1)                    //arithmetic shift
						begin
							if(IF_ID_opcode[0] == 1'b0)
								operation = shift_ari_left;                   //arith shift left
							else
								operation = shift_ari_right;                  //arith shift right
						end
					else
						operation = 4'bxxxx;                                //unknown operation
					end
				
				nop: begin                                                //includes only nop
					counter_ID_en = 1'b1;                                  //enable the counter
					//rest all need not be cared; so this is written
					reg_addr_read1 = 4'dx;
					reg_addr_read2 = 4'dx;
					reg_addr_write = 4'dx;
					operation = 4'dx;
					reg_data_write = 16'dx;
					mem_addr_write = 8'dx;
					mem_addr_read = 8'dx;
					mem_data_write = 16'dx;
				end
				
				default: begin
					counter_ID_en = 1'b0;                                  //disable the counter
					//rest all need not be cared; so this is written
					reg_addr_read1 = 4'dx;
					reg_addr_read2 = 4'dx;
					reg_addr_write = 4'dx;
					operation = 4'dx;
					reg_data_write = 16'dx;
					mem_addr_read = 8'dx;
					mem_addr_write = 8'dx;
					mem_data_write = 16'dx;
				end
			endcase
		end
	
	//instantiate the counter for NOP
	counter COUNT_ID(.clock(clock),.reset(reset),.en(counter_ID_en),.count(count_ID));
	
	//intermediate between ID and EX stages
	always@(posedge clock)                        //sequential logic for moving these into registers
		begin
			ID_EX_opcode <= IF_ID_opcode;
			ID_EX_instruction <= IF_ID_instruction;
			ID_EX_reg_data_read1 <= reg_data_read1;
			ID_EX_reg_data_read2 <= reg_data_read2;
			ID_EX_mem_data_read <= mem_data_read;
			ID_EX_reg_signal_write <= reg_signal_write;
			ID_EX_reg_addr_write <= reg_addr_write;
			ID_EX_reg_data_write <= reg_data_write;
			ID_EX_mem_signal_write <= mem_signal_write;
			ID_EX_mem_addr_write <= mem_addr_write;
			ID_EX_mem_data_write <= mem_data_write;
			ID_EX_operation <= operation;
		end
	
	//assigning to see what are being read in the processor
	assign reg_read1_addr = reg_addr_read1;
	assign reg_read2_addr = reg_addr_read2;
	assign reg_read1_data = reg_data_read1;
	assign reg_read2_data = reg_data_read2;
	assign mem_read_address = mem_addr_read;
	assign mem_read_data = mem_data_read;
	
	//execute stage
	always@(*)                                        //combinational logic to decode operands for the ALU
		begin
			case(ID_EX_opcode[3:1])                         //consider the instruction classification
				andor_inst, addsub_inst: begin               //includes and,or,add,sub
					//two register sources
					alu_op1 = ID_EX_reg_data_read1;           //move this read1 data to alu
					alu_op2 = ID_EX_reg_data_read2;           //move this read2 data to alu
					end
				
				notxor_inst, div_inst: begin                 //includes not,xor,div
					if(ID_EX_opcode[0] == 1'b0)               //xor, div instructions
						begin
							alu_op1 = ID_EX_reg_data_read1;     //move this to alu; one sure-shot register source
							alu_op2 = ID_EX_reg_data_read2;     //move this to alu; the second register source
						end
					//not instruction
					else if((ID_EX_opcode[3:1] == notxor_inst) && (IF_ID_opcode[0] == 1'b1))
						begin
							alu_op1 = ID_EX_reg_data_read1;     //move this to alu; one sure-shot register source
							alu_op2 = 16'dx;                    //no  need of this operand here
						end
					else                                      //unknown operands for inknown operation
						alu_op1 = 16'dx;
						alu_op2 = 16'dx;
					end
				
				shift_inst: begin                            //includes shl,shr
					alu_op1 = ID_EX_reg_data_read1;           //move this to alu; one register source
					//condition based operands
					alu_op2 = {13'd0,ID_EX_instruction[2:0]}; //move this shift amount data to alu
					end
				
				nop: begin                                              //includes only nop
						counter_EX_en = 1'b1;                             //enable the counter
						//rest all need not be cared; so this is written
						alu_op1 = 16'dx;
						alu_op2 = 16'dx;
					end
				
				default: begin
						counter_EX_en = 1'b0;                             //enable the counter
						//rest all need not be cared; so this is written
						alu_op1 = 16'dx;
						alu_op2 = 16'dx;
					end
			endcase
		end
	
	//instantiating the counter for NOP
	counter COUNT_EX(.clock(clock),.reset(reset),.en(counter_EX_en),.count(count_EX));
	
	//instantiating arithmetic and logical unit (alu)
	arithmetic_logical_unit ALU(
			.operation(ID_EX_operation),
			.alu_op1(alu_op1),
			.alu_op2(alu_op2),
			.alu_res(alu_res),
			.zero_flag(zero_flag),
			.negative_flag(negative_flag),
			.error_flag(error_flag)
	);
	
	//intermediate between EX and MEM stages
	always@(posedge clock)                           //sequential logic for moving these into registers
		begin
			EX_MEM_operation <= ID_EX_operation;
			EX_MEM_mem_signal_write <= ID_EX_mem_signal_write;
			EX_MEM_mem_addr_write <= ID_EX_mem_addr_write;
			EX_MEM_mem_data_write <= ID_EX_mem_data_write;
			EX_MEM_reg_signal_write <= ID_EX_reg_signal_write;
			EX_MEM_reg_addr_write <= ID_EX_reg_addr_write;
			
			//reg_data_write has two different results: alu_res or reg_data_write
			if((ID_EX_opcode[3:1]==mem_data_inst) && (ID_EX_opcode[0] == 1'b0))
				EX_MEM_reg_data_write <= ID_EX_reg_data_write;        //push the reg_write_data
			else if(ID_EX_opcode[3:1]==reg_data_inst)
				EX_MEM_reg_data_write <= ID_EX_reg_data_write;        //push the reg_write_data
			else
				EX_MEM_reg_data_write <= alu_res;                     //push the alu result
		end
	
	//assigning to see what's going on in the ALU
	assign current_operation = EX_MEM_operation;
	assign alu_in_1 = alu_op1;
	assign alu_in_2 = alu_op2;
	assign alu_out = alu_res;
	
	//memory access stage
	//instantiating data memory
	data_memory DM(
			.clock(clock),
			.mem_addr_read(mem_addr_read),
			.mem_data_read(mem_data_read),
			.mem_signal_write(EX_MEM_mem_signal_write),
			.mem_addr_write(EX_MEM_mem_addr_write),
			.mem_data_write(EX_MEM_mem_data_write),
			.data_retained(mem_data_retained)
	);
	
	//assigning these to show what's going on in data memory
	assign mem_write = EX_MEM_mem_signal_write;
	assign mem_write_address = EX_MEM_mem_addr_write;
	assign mem_write_data = EX_MEM_mem_data_write;
	
	//intermediate between MEM and WB stages
	always@(posedge clock)                           //sequential logic for moving these into registers
		begin
			MEM_WB_reg_signal_write <= EX_MEM_reg_signal_write;
			MEM_WB_reg_addr_write <= EX_MEM_reg_addr_write;
			MEM_WB_reg_data_write <= EX_MEM_reg_data_write;
		end
	
	//write back registers stage
	//instantiating register file
	register_file RF(
			.clock(clock),
			.reg_addr_read1(reg_addr_read1),
			.reg_addr_read2(reg_addr_read2),
			.reg_data_read1(reg_data_read1),
			.reg_data_read2(reg_data_read2),
			.reg_signal_write(MEM_WB_reg_signal_write),
			.reg_addr_write(MEM_WB_reg_addr_write),
			.reg_data_write(MEM_WB_reg_data_write),
			.data_retained(reg_data_retained)
	);
	
	//assigning these to show what's going on in register file
	assign reg_write = MEM_WB_reg_signal_write;
	assign reg_write_address = MEM_WB_reg_addr_write;
	assign reg_write_data = MEM_WB_reg_data_write;
endmodule
