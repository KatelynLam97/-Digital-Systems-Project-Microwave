module pwmGenerator #(parameter CLOCK_FREQUENCY = 50000000) (clock, reset, enable, masterEnable,fastClock, heatingLevel,pwmOut, ledOn);
	input clock, reset, enable, masterEnable, fastClock;
	input [1:0] heatingLevel;
	wire onEnOut;
	output wire ledOn;
	reg [7:0] duty_cycle;
	output pwmOut;
	
	assign pwmOut = ledOn & onEnOut;
	
	always@(*)
	begin
		if(reset)
			duty_cycle <= 7'd50;
		//select duty cycle based on entered heatingLevel
		case(heatingLevel)
			2'b00: duty_cycle <= 7'd10; //LOW heating level
			2'b01: duty_cycle <= 7'd30; //MEDIUM heating level
			2'b10: duty_cycle <= 7'd50; //NORMAL heating level
			2'b11: duty_cycle <= 7'd80; //HIGH heating level
			default: duty_cycle <= 7'd50;
		endcase
	end
		
	pwm_counter #(.NUM_BITS($clog2(CLOCK_FREQUENCY)))on (clock, reset, enable, masterEnable, fastClock,duty_cycle * CLOCK_FREQUENCY/'d100, ledOn,onEnOut); //counts number of on cycles

endmodule