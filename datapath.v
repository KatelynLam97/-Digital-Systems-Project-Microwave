//datapath module
//inputs: clock, reset, start, loadDuration, loadHeat, loadAutoMode, iDuration, iAutoMode, iHeatingLevel
//outputs: oMicrowaveClock, oHeatPulse
`timescale 1ns/1ns
/* ECE241 FINAL PROJECT - Katelyn Lam (rev.2023-11-18)
   Datapath module. To be paired with control module.
		Inputs
			- clock: 50MHz clock from De1-SoC board. Simulated as a square wave with period 2ns on ModelSim.
			- reset: Active HIGH
			- controlReset: if user decides to stop the microwave in the middle of operation, FSM will move to a reset (clear) state which also
				triggers a reset
			- start: input from switch, to signal cooking
			- loadDuration: enable for register to load cook duration (durationReg)
			- loadHeat: enable for register to load heating level (heatLevelReg)
			- iDuration: 16-bit input for cook time, ranging from 0 - 99min 99s
			- iHeatingLevel: 2-bit input for heating level (see pwmGenerator.v for more details)
		Outputs
			- oMicrowaveClock: 1s clock pulse. Input to VGA output module
			- oHeatPulse : PWM output (simulates cooking)
			- oDone : signals done cooking operation. Triggers "end" screen
*/

module datapath(clock, reset, controlReset, start,loadDuration, loadHeat, iDuration, iHeatingLevel, oMicrowaveClock, oHeatPulse, oDone, motorSwitch, count, durationOut);
	input wire clock, reset, controlReset, start, loadDuration, loadHeat;
	input wire [15:0] iDuration;
	input wire [1:0] iHeatingLevel;
	output wire [15:0] durationOut;
	output wire [15:0] count;
	wire [1:0] heatOut;
	
	//set reset to either external reset or clear state in control
	wire dataReset, durationLoad, oneSClock, pwmClock, pwmOutput,latchEnable;
	assign dataReset = reset | controlReset; 
	
	output reg oMicrowaveClock, oHeatPulse;
	output wire oDone, motorSwitch;
	
	//assign durationOut = loadDuration;
		
	//Registers to store cook time and heat level
	durRegister durationReg(clock, dataReset, loadDuration, iDuration, durationOut);
	register #(.NUM_BITS(2)) heatLevelReg(clock, dataReset, loadHeat, iHeatingLevel, heatOut);
	
						
	
	oneSCounter #(.CLOCK_FREQUENCY(50000000)) sClock(clock,reset,start,oneSClock); //generates pulse every 1s
	pwmClock #(.CLOCK_FREQUENCY(50000000)) pwmClockCounter(clock,reset,start,pwmClock);
	
	//outputs 1s pulse only if microwave is still cooking, by counting up to a certain duration
	counter #(.NUM_BITS(16)) microwaveTimer (oneSClock, dataReset, start, durationOut, count, oDone); 
	enableLatch pwmEnable(clock,dataReset,oneSClock,oDone,start,latchEnable);
	
	pwmGenerator #(.CLOCK_FREQUENCY(50000000)) pwmPulse(clock,dataReset, latchEnable, oneSClock,pwmClock,iHeatingLevel,pwmOutput, motorSwitch); //generates PWM signal based on duty cycle
	
	//Note that oneSCounter is always on. datapath only outputs this pulse if microwave is in a cooking state.
	always@(*)
	begin
		if(!oDone)
		begin
			oMicrowaveClock <= oneSClock;
			oHeatPulse <= pwmOutput;
		end
		else
		begin
			oMicrowaveClock <= 1'b0;
			oHeatPulse <= 1'b0;
		end
	end
endmodule