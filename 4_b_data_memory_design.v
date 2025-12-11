//data memory of processor
module data_memory(
	input clock,                                  //processor clock
	input mem_signal_write,                       //write signal
	input [7:0]mem_addr_write,                    //write address
	input [7:0]mem_addr_read,                     //read address
	input [15:0]mem_data_write,                   //write data
	output [15:0]mem_data_read,                   //read data
	output reg data_retained                          //update signal
);
	reg [15:0]memory[0:255];                 //data memory of 256 words each of 16 bits
	integer i;                               //for loop variable
	
	initial                                  //initial values are made zeroes
		begin
			for(i=0;i<256;i=i+1)
				memory[i] <= 16'd0;             //initialising memory words as zeroes
		end
	always@(posedge clock)                   //sequential logic for writing to memory
		begin
			if((mem_signal_write == 1'b1) && !(mem_data_write === 16'dx))       //writing condition
				begin
					memory[mem_addr_write] <= mem_data_write;       //write assignment
					data_retained = 1'b0;                           //data updated
				end
			else
				begin
					memory[mem_addr_write] <= memory[mem_addr_write];
					data_retained = 1'b1;                           //data not updated
				end
		end
	assign mem_data_read = memory[mem_addr_read];      //read assignment
endmodule