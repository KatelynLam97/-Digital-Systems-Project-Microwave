//PWM clock. Pulses at a higher frequency (100x higher) than oneSCounter.
module pwmClock #(parameter CLOCK_FREQUENCY = 5000000) (clock, reset, enable, outEnable);

	input clock, reset, enable;
	output outEnable;
	
	rate_counter #(.NUM_BITS($clog2(CLOCK_FREQUENCY))) pwmFastClock (clock, reset, enable, CLOCK_FREQUENCY-1, outEnable); //change to actual conditions when testing GPIO
endmodule