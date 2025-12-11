//clock divider module to generate slower clock
module clock_divider(
	input clock_in,                    //input fast clock
	output reg clock_out               //output slow clock
);
	reg [15:0]count = 16'd0;           //initial value of the counter is 0
	always@(clock_in)
		begin
			count <= count + 19'd1;      //increment counter by every edge
			clock_out <= count[3];       //new_clock_frequency = old_clock_frequency * (2^n)
		end
endmodule

//decoder to convert 4-bit value onto seven segment display
module segment_decoder(
	input [3:0]value,        //4-bit value
	output reg [0:6]segment  //format is ABCDEFG
);
	always@(*)
		//based on the value the segments are turned on; else all off
		case(value[3:0])
			4'b0000: segment = 7'b0000001;
			4'b0001: segment = 7'b1001111;
			4'b0010: segment = 7'b0010010;
			4'b0011: segment = 7'b0000110;
			4'b0100: segment = 7'b1001100;
			4'b0101: segment = 7'b0100100;
			4'b0110: segment = 7'b0100000;
			4'b0111: segment = 7'b0001111;
			4'b1000: segment = 7'b0000000;
			4'b1001: segment = 7'b0000100;
			4'b1010: segment = 7'b0001000;
			4'b1011: segment = 7'b1100000;
			4'b1100: segment = 7'b0110001;
			4'b1101: segment = 7'b1000010;
			4'b1110: segment = 7'b0110000;
			4'b1111: segment = 7'b0111000;
			default: segment = 7'b1111111;
		endcase
endmodule