`timescale 1ns / 1ns // `timescale time_unit/time_precision

/* Module to convert 4 bit signal to 7 bit output, for the 7-seg display.
Inputs:
- c: 4-bit input, value from HEX0-F.
- enable: If LOW, do not turn on anysegments
Outputs:
- display: 7 bit output, to be displayed on 7 segment display
*/

module hex_decoder(c, display, enable);

	input enable;
	
	//initialize inputs
	input [3:0] c;
	
	//initialize outputs, corresponding to LED on 7-seg
	output reg [6:0] display;
	
	
	always@(*)
	begin
		if(!enable)
			display <= 7'b1111111;
		else
		begin
			//boolean equations for each output
			display[6] <= (!c[0]&!c[1]&!c[2]&!c[3])|(c[0]&!c[1]&!c[2]&!c[3])
							|(c[0]&c[1]&c[2]&!c[3])|(!c[0]&!c[1]&c[2]&c[3]);
							
			display[5] <= (c[0]&!c[1]&!c[2]&!c[3])|(!c[0]&c[1]&!c[2]&!c[3])
							|(c[0]&c[1]&!c[2]&!c[3])|(c[0]&c[1]&c[2]&!c[3])
							|(c[0]&!c[1]&c[2]&c[3]);
							
			display[4] <= (c[0]&!c[1]&!c[2]&!c[3])|(c[0]&c[1]&!c[2]&!c[3])
							|(!c[0]&!c[1]&c[2]&!c[3])|(c[0]&!c[1]&c[2]&!c[3])
							|(c[0]&c[1]&c[2]&!c[3])|(c[0]&!c[1]&!c[2]&c[3]);
							
			display[3] <= (c[0]&!c[1]&!c[2]&!c[3])|(!c[0]&!c[1]&c[2]&!c[3])
							|(c[0]&c[1]&c[2]&!c[3])|(!c[0]&c[1]&!c[2]&c[3])
							|(c[0]&c[1]&c[2]&c[3]);
		
			display[2] <= (!c[0]&c[1]&!c[2]&!c[3])|(!c[0]&!c[1]&c[2]&c[3])
							|(!c[0]&c[1]&c[2]&c[3])|(c[0]&c[1]&c[2]&c[3]);
							
			display[1] <= (c[0]&!c[1]&c[2]&!c[3])|(!c[0]&c[1]&c[2]&!c[3])
							|(c[0]&c[1]&!c[2]&c[3])|(!c[0]&!c[1]&c[2]&c[3])
							|(!c[0]&c[1]&c[2]&c[3])|(c[0]&c[1]&c[2]&c[3]);
		
			display[0] <= (c[0]&!c[1]&!c[2]&!c[3])|(!c[0]&!c[1]&c[2]&!c[3])
							|(c[0]&c[1]&!c[2]&c[3])|(c[0]&!c[1]&c[2]&c[3]);
		end
	end
endmodule