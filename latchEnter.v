module latchEnter(clock, reset, enterIn, enterOut);
	input clock, reset;
	input wire enterIn;
	output wire enterOut;
	reg q;
	
	toggleEnter enterReg(q,enterIn,enterOut);
	
	always@(posedge clock, posedge reset)
	begin
		if(reset)
			q <= 1'b0;
		else
			q <= 1'b1;
	end
endmodule

module toggleEnter(q, enterIn,enterOut);
	input q, enterIn;
	output reg enterOut;
	
	always@(*)
	begin
		if(q == 1'b0)
			enterOut <= enterIn;
		else
			enterOut <= 1'b0;
	end
endmodule

			