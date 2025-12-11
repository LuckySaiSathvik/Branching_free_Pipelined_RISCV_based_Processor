//testbench for checking fpga mapping into processor
module fpga_mapping_tb;
	//inputs are declared reg
	reg clock_pin;              //processor clock
	reg reset_pin;              //processor reset
	reg data_show;              //flip between data and instruction
	//outputs are declared wire
	//multi bit outputs
	wire [7:0]program_counter;  //program counter value
	wire [15:0]instruction;     //instruction value
	wire [15:0]data_result;     //data being processed
	wire [15:0]show_this;       //showing any of instruction or data
	//flags and signals
	wire instr_stop_show;       //instruction stop signal
	wire zero_flag_show;        //zero flag
	wire negative_flag_show;    //negative flag
	wire error_flag_show;       //error flag
	wire mem_data_retained_show;//data retained in memory
	wire reg_data_retained_show;//data retained in register file
	//6 seven segment displays
	wire [6:0]seg5;
	wire [6:0]seg4;
	wire [6:0]seg3;
	wire [6:0]seg2;
	wire [6:0]seg1;
	wire [6:0]seg0;
	
	//instantiating the fpga mapping of the processor
	fpga_mapping IMPLEMENT(//inputs to the module
									.clock(clock_pin),
									.reset(reset_pin),
									.data_show(data_show),
									//multi bit outputs
									.program_counter(program_counter),
									.data_result(data_result),
									.show_this(show_this),
									.instruction(instruction),
									//flags and signals
									.instr_stop_show(instr_stop_show),
									.zero_flag_show(zero_flag_show),
									.negative_flag_show(negative_flag_show),
									.error_flag_show(error_flag_show),
									.mem_data_retained_show(mem_data_retained_show),
									.reg_data_retained_show(reg_data_retained_show),
									//seven segment displays
									.seven_seg_0(seg0),
									.seven_seg_1(seg1),
									.seven_seg_2(seg2),
									.seven_seg_3(seg3),
									.seven_seg_4(seg4),
									.seven_seg_5(seg5)
	);
	
	//initial values to test the design particularly the inputs
	initial
		begin
			clock_pin = 1'b1;
			reset_pin = 1'b0;
			data_show = 1'b0;
		end
	always #5 clock_pin = ~clock_pin;   //clock period is 10 units
	
	initial
		begin
			#10 reset_pin = 1'b1;          //initially give reset
			#10 reset_pin = 1'b0;         //bring processor back to normal
			#100 data_show = 1'b1;        //now show data being processed
			#100 data_show = 1'b0;        //show the instruction
			#1000 $finish;                //stop execution
		end
endmodule
