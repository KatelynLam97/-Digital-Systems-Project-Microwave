/* ECE241 FINAL PROJECT - Katelyn Lam (rev.2023-11-26)
   Microwave FSM 
		Inputs
			- clock: 50MHz clock from De1-SoC board. Simulated as a square wave with period 2ns on ModelSim.
			- reset: Active HIGH
			- modeSelect: SW. Position 0 (off) - manual, position (on) 1 - auto
			- keyboardEnter: PS2 keyboard enter input. Use to finish loading duration, heating level for manual mode. Connect to: Keyboard input module
			- keyDuration: 16-bit keyboard input for duration. Connect to: Keyboard Input module
			- manualHeatLevel: SW(2). Select heating level (see pwmGenerator.v).
			- manualStart: SW. Put in on position to indicate start
			- keyAutoChanged: indicator from keyboard converter module indicating appropriate key pressed
			- manualStop: KEY. Press to indicate temporary stop. Press again to CLEAR
			- keyAutoMode: PS2 keyboard to select input for auto heating levels. Connect to: Keyboard input module
				- p – popcorn
				- o – potato
				- m – meat
				- v – veggies 
				- b - beverage
				- r – reheat
				- d – defrost
				- a – auto

		Outputs
			- oMicrowaveClock: 1s clock pulse. Input to VGA output module
			- oPWM : PWM output (simulates cooking)
			- oDone : signals done cooking operation. Signals "end" screen
	REVISIONS:
	- Added keyAutoChanged parameter to FSM
	- Changed Load to active high
*/

`timescale 1ns/1ns
module microwave(clock, reset, modeSelect, keyboardEnter, keyUpdated, keyDuration, manualHeatLevel, manualStart, keyAutoChanged, manualStop,keyAutoMode, enDuration, enHeatingLevel, oMicrowaveClock, oPWM, motorSwitch,  oDone, currentState, count, durationOut);
	input wire clock, reset, modeSelect, keyboardEnter, keyUpdated, manualStart,manualStop, keyAutoChanged;
	input wire [15:0] keyDuration;
	input wire [1:0] manualHeatLevel;
	input wire [2:0] keyAutoMode;
	wire doneOut,datapath_start, data_reset;
	wire [15:0] durationLoad;
	wire [1:0] heatLevelLoad;
	output wire [3:0] currentState;
	output wire enDuration, enHeatingLevel, oMicrowaveClock, oPWM, motorSwitch, oDone;
	output wire [15:0] durationOut, count;
	
	
	
	control controlFSM(.clock(clock),
					   .reset(reset),
					   .selectMode(modeSelect),
					   .doneCount(doneOut),
					   .load(keyboardEnter),
						.newKeyPressed(keyUpdated),
					   .start(manualStart),
					   .startAuto(keyAutoChanged),
					   .stop(manualStop),
					   .keyDuration(keyDuration),
					   .autoMode(keyAutoMode),
					   .manualHeatLevel(manualHeatLevel),
					   .enDuration(enDuration),
					   .enHeatingLevel(enHeatingLevel),
					   .enOut(datapath_start),
					   .enEnd(oDone),
					   .enReset(data_reset),
					   .inDuration(durationLoad),
					   .inHeatLevel(heatLevelLoad),
						.stateReg(currentState));
					   
	datapath microwaveOut(.clock(clock),
						  .reset(reset),
						  .controlReset(data_reset),
						  .start(datapath_start),
						  .loadDuration(enDuration),
						  .loadHeat(enHeatingLevel),
						  .iDuration(durationLoad),
						  .iHeatingLevel(heatLevelLoad),
						  .oMicrowaveClock(oMicrowaveClock),
						  .oHeatPulse(oPWM),
						  .oDone(doneOut),
						  .durationOut(durationOut),
						  .count(count),
						  .motorSwitch(motorSwitch));
						  						
endmodule

//AUXILIARY MODULES

//register to store a value at positive clock edge. Note this is triggered by an enable.
//Active HIGH reset
module register #(parameter NUM_BITS = 4)(clock, reset, enable, data, Q);
	input clock, reset, enable;
	input [NUM_BITS-1:0] data;
	output reg [NUM_BITS-1:0] Q;
	
	always@ (posedge reset, posedge clock)
	begin
		if(reset)
			Q <= 'b0;
		else
		begin
			if(enable)
				Q <= data;
		end
	end
endmodule

module durRegister (clock, reset, enable, data, Q);
	input clock, reset, enable;
	input [15:0] data;
	output reg [15:0] Q;
	
	always@ (posedge reset, posedge clock)
	begin
		if(reset)
			Q <= 'b0;
		else
		begin
			if(enable)
				//Q <= data;
				Q <= data[15:12] * 16'b0000001111101000 + data[11:8] * 16'b0000000001100100 + data[7:4] * 16'b0000000000001010 + data[3:0] * 16'b0000000000000001;
		end
	end
endmodule

//counter counting up from 0 to parLoad. Output done when finished.
//Active HIGH reset
module counter #(parameter NUM_BITS = 4)(clock, reset, enable, parLoad, Q, done);
	input clock, enable, reset;
	input [NUM_BITS-1:0] parLoad; 
	output reg [NUM_BITS-1:0] Q; 
	output reg done; 
	
	always@ (posedge clock, posedge reset)
	begin
		if(reset)
		begin
			Q <= 'b0;
			done <= 1'b0;
		end
		else
		begin
			if(enable)
			begin
				if(Q < parLoad | (Q == 'b0 & parLoad == 'b0))
				begin
					done <= 1'b0;
					Q <= Q + 1;
				end
				else
				begin
					done <= 1'b1;
					Q <= 'b0;
				end
			end
		end
	end
endmodule


