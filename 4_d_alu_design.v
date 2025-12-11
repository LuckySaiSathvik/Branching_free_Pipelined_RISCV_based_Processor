//alu of processor
module arithmetic_logical_unit(
	input [3:0]operation,                          //alu operation
	input [15:0]alu_op1,                           //alu 1st operand
	input [15:0]alu_op2,                           //alu 2nd operand
	output reg [15:0]alu_res,                      //alu result
	output reg zero_flag,                          //zero flag
	output reg negative_flag,                      //negative flag
	output reg error_flag                          //error flag
);	
	//classification of operations
	localparam bit_and = 4'b0000,                //and
		  bit_or = 4'b0001,                       //or
		  bit_xor = 4'b0010,                      //xor
		  bit_not = 4'b0011,                      //not
		  shift_log_left = 4'b0100,               //logic shift left
		  shift_ari_left = 4'b0101,               //arith shift left
		  shift_log_right = 4'b0110,              //logic shift right
		  shift_ari_right = 4'b0111,              //arith shift right
		  arith_add = 4'b1000,                    //add
		  arith_sub = 4'b1001,                    //sub
		  arith_div = 4'b1010;                    //div
	always @(*)                                  //combinational logic for the operation selection
		begin
			case(operation)                                   //perform based on the given operation
				bit_and: begin
								alu_res = alu_op1 & alu_op2;                   //and
								zero_flag = (alu_res == 16'd0);                //set if result is zero
								negative_flag = (alu_res < 16'd0);             //set if result is negative
								error_flag = (alu_res === 16'dx);              //set if result is undefined
							end
				
				bit_or: begin
								alu_res = alu_op1 | alu_op2;                   //or
								zero_flag = (alu_res == 16'd0);                //set if result is zero
								negative_flag = (alu_res < 16'd0);             //set if result is negative
								error_flag = (alu_res === 16'dx);              //set if result is undefined
							end
				
				bit_xor: begin
								alu_res = alu_op1 ^ alu_op2;                   //xor
								zero_flag = (alu_res == 16'd0);                //set if result is zero
								negative_flag = (alu_res < 16'd0);             //set if result is negative
								error_flag = (alu_res === 16'dx);              //set if result is undefined
							end
				
				bit_not: begin
								alu_res = (~alu_op1);                          //not or complement
								zero_flag = (alu_res == 16'd0);                //set if result is zero
								negative_flag = (alu_res < 16'd0);             //set if result is negative
								error_flag = (alu_res === 16'dx);              //set if result is undefined
							end
				
				shift_log_left: begin
								alu_res = alu_op1 << alu_op2;                  //logical left shift
								zero_flag = (alu_res == 16'd0);                //set if result is zero
								negative_flag = (alu_res < 16'd0);             //set if result is negative
								error_flag = (alu_res === 16'dx);              //set if result is undefined
							end
				
				shift_ari_left: begin
								alu_res = alu_op1 <<< alu_op2;                 //arithmetic left shift
								zero_flag = (alu_res == 16'd0);                //set if result is zero
								negative_flag = (alu_res < 16'd0);             //set if result is negative
								error_flag = (alu_res === 16'dx);              //set if result is undefined
							end
				
				shift_log_right: begin
								alu_res = alu_op1 >> alu_op2;                  //logical right shift
								zero_flag = (alu_res == 16'd0);                //set if result is zero
								negative_flag = (alu_res < 16'd0);             //set if result is negative
								error_flag = (alu_res === 16'dx);              //set if result is undefined
							end
				
				shift_ari_right: begin
								alu_res = alu_op1 >>> alu_op2;                 //arithmetic right shift
								zero_flag = (alu_res == 16'd0);                //set if result is zero
								negative_flag = (alu_res < 16'd0);             //set if result is negative
								error_flag = (alu_res === 16'dx);              //set if result is undefined
							end
				
				arith_add: begin
								if(alu_op1 + alu_op2 <= 16'hFFFF)             //if no overflow
									alu_res = alu_op1 + alu_op2;                //add
								else
									alu_res = 16'dx;                            //possible data violations
								
								zero_flag = (alu_res == 16'd0);                //set if result is zero
								negative_flag = (alu_res < 16'd0);             //set if result is negative
								error_flag = (alu_res === 16'dx);              //set if result is undefined
							end
				
				arith_sub: begin
								if(alu_op1 - alu_op2 <= 16'hFFFF)              //if no overflow
									alu_res = alu_op1 - alu_op2;                //subtract
								else
									alu_res = 16'dx;                            //possible data violations
								
								zero_flag = (alu_res == 16'd0);                //set if result is zero
								negative_flag = (alu_res < 16'd0);             //set if result is negative
								error_flag = (alu_res === 16'dx);              //set if result is undefined
							end
				
				arith_div: begin
								if(alu_op2 != 16'd0)                           //if not divide by zero
									alu_res = alu_op1 / alu_op2;                //divide
								else
									alu_res = 16'dx;                            //possible data violations
								
								zero_flag = (alu_res == 16'd0);                //set if result is zero
								negative_flag = (alu_res < 16'd0);             //set if result is negative
								error_flag = (alu_res === 16'dx);              //set if result is undefined
							end
				
				default: begin
								alu_res = 16'dx;                 //undefined operation
								zero_flag = 1'b0;                //set if result is zero
								negative_flag = 1'b0;            //set if result is negative
								error_flag = 1'b1;               //set if result is undefined
							end
			endcase
		end
endmodule
