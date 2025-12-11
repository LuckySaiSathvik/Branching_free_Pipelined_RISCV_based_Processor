//register file of processor
module register_file(
	input clock,                               //clock of processor
	input reg_signal_write,                    //write signal
	input [3:0]reg_addr_write,                 //write address
	input [3:0]reg_addr_read1,                 //read address 1
	input [3:0]reg_addr_read2,                 //read address 2
	input [15:0]reg_data_write,                //write data
	output [15:0]reg_data_read1,               //read data 1
	output [15:0]reg_data_read2,               //read data 2
	output reg data_retained                   //update signal
);
	reg [15:0]register_file[0:15];             //register file
	integer i;                                 //for loop variable
	
	initial                                             //initial values are made zeroes
		begin
			for(i=0;i<16;i=i+1)
				register_file[i] <= 16'd0;                 //initialising register words as zeroes
		end
	always@(posedge clock)                              //sequential logic for writing to register file
		begin
			if((reg_signal_write==1'b1) && !(reg_data_write === 16'dx))//writing
				begin
					register_file[reg_addr_write] <= reg_data_write;//write assignment
					data_retained = 1'b0;                           //data updated
				end
			else
				begin
					register_file[reg_addr_write] <= register_file[reg_addr_write];
					data_retained = 1'b1;                          //data not updated
				end
		end
	assign reg_data_read1 = register_file[reg_addr_read1];                 //read assignment 1
	assign reg_data_read2 = register_file[reg_addr_read2];                 //read assignment 2
endmodule