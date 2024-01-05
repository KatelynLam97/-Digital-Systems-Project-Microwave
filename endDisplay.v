/* ECE241 FINAL PROJECT - Katelyn Lam (rev.2023-11-26)
	Module to display "End" on 7-segment display. Pulses every 1s.
	Input:
		CLOCK_50 - 50 MHz clock on FPGA
		enable - enOut connected to control module. Displays End when HIGH
		reset - Active HIGH
	Output:
		HEX - 7-segment display used to show "End"
*/
module endDisplay(clock, enable, reset, hexOut2, hex1Out, hex0Out);
	input clock, enable,reset;
	output reg [6:0] hex0Out, hex1Out, hexOut2;
	wire oneSecondClock, toggleOut;
	
	oneSCounter #(.CLOCK_FREQUENCY(50000000)) oneSClock(clock,reset,enable,oneSecondClock);
	endToggle blink(oneSecondClock,reset,enable,toggleOut); //turns on and off the "End" every second
	
	always@(posedge clock)
	begin
		if(reset)
		begin
			hex0Out <= 7'b1111111;
			hex1Out <= 7'b1111111;
			hexOut2 <= 7'b1111111;
		end
		else if(!enable)
		begin
			hex0Out <= 7'b1111111;
			hex1Out <= 7'b1111111;
			hexOut2 <= 7'b1111111;
		end
		else 
		begin
			if(!toggleOut)
			begin
				hex0Out <= 7'b1111111;
				hex1Out <= 7'b1111111;
				hexOut2 <= 7'b1111111;
			end
			
			else
			begin
				hex0Out <= 7'b0100001;
				hex1Out <= 7'b0101011;
				//hexOut2 <= 7'b0000110;                                                                                                                                                                     h000110;
			end
		end
	end
endmodule

module endToggle(clock, reset, enable, out);
	input clock, reset, enable;
	output reg out;
	
	always@(posedge clock, posedge reset)
	begin
		if(reset)
			out <= 1'b0;
		else
		begin
			if(enable)
				out <= ~out;
		end
	end
endmodule