`timescale 1ns/1ns
/* ECE241 FINAL PROJECT - Katelyn Lam (rev.2023-11-18)
	Module for counter to time 1s given an input clock frequency. On the De1-SoC board, this would be 50MHz.
	However, for our modelSim test cases we generated a square wave clock with a period of 2ns, and scaled
	1s -> 20ns for testing.
	
	These modules are based on our work for Lab 5 Pt.2.
	
	oneSCounter - top level module. 1s clock signal outputted through outEnable. 
	Notes:
		- Active HIGH reset
		- enable is the start input (see control module)
*/
module HundredMSCounter #(parameter CLOCK_FREQUENCY =50000000)(clock, reset, enable, outEnable);

	input clock, reset, enable;
	output outEnable;
	
	rate_counter #(.NUM_BITS($clog2(CLOCK_FREQUENCY))) oneMSDivider (clock, reset, enable, CLOCK_FREQUENCY/10-1, outEnable);
endmodule

