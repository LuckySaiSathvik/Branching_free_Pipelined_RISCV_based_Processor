//code for the NOP counter
module counter(
	input clock,                               //processor clock
	input reset,                               //processor reset
	input en,                                  //counter enable
	output reg [3:0]count                      //count value
);
	always@(posedge clock)                     //sequential logic to count
		begin
			//counts only if enabled; otherwise retained
			if(reset && en)
				count <= 4'd0;
			else if (en)
				count <= count + 4'd1;
			else
				count <= count;
		end
endmodule