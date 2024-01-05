`timescale 1ns/1ns
/* ECE241 FINAL PROJECT - Katelyn Lam (rev.2023-11-28)
   KeyboardConvertIn. To be chained with PS2 keyboard input module. 
                      Takes input from keyboard and converts to values of keyboardEnter, keyDuration, keyAutoMode
		Inputs
			- reset: Active high
			- keyIn: input (to connect to PS2 keyboard input module). Signifies when a key has been pressed.
			- keyHexIn: data value (to connect to PS2 keyboard input module). value of keyboard mapped to 8-bit value, represented in HEX.
			- checkLoad: state of whether enter is being checked (i.e. enable in INPUT_TIME, INPUT_HEAT_LEVEL states)
			- checkDuration: state of whether duration is being entered (i.e. enable in INPUT_TIME)
			- selectAuto: mode parameter (0 - manual, 1 for auto)

		Outputs
			- enterOut: HIGH when enter is pressed during a checkLoad state, otherwise latch on to previous value
			- durationOut: 16-bit output indicating cook time in seconds
			- autoOut: 3-bit automatic cook mode 
				- 000 – popcorn
				- 001 – potato
				- 010 – meat
				- 011 – veggies 
				- 100 - beverage
				- 101 – reheat
				- 110 – defrost
				- 111 – auto
			- autoSet: HIGH when valid key is pressed. Indicator for state transition from PROCESS_IN to an automatic mode

		Revisions:
			- For the shift register, did an enable to prevent against debounce
			
		- Take an enter, Wait 100ms and set to LOW.
*/
module keyboardConvertIn2 (reset, keyIn, keyHexIn, checkLoad, checkDuration, selectAuto, enterOut, durationOut,autoOut, autoSet, validDurKey);
	input reset, keyIn,checkLoad, checkDuration, selectAuto;
	input[7:0] keyHexIn;
	reg [3:0] durationAdded;
	output reg validDurKey;
	output reg enterOut;
	output wire [15:0] durationOut;
	output reg [2:0] autoOut;
	output reg autoSet;
	
	
	shiftRegister shiftReg(reset,validDurKey,durationAdded,durationOut);
	
	//only respond to reset or change in keyboard values
	always@(posedge keyIn, posedge reset)
	begin
		if(reset)
		begin
			enterOut <= 'b0;
			//durationOut <= 'b0;
			autoOut <= 'b0;
			validDurKey <= 'b0;
			durationAdded <= 'b0;
		end
		else
		begin
			if(checkLoad) //check for enter pressed
				enterOut <= (keyHexIn == 8'h5A) ? 1'b1 : 1'b0;

			//while enter is not pressed, but duration is being entered, use a shift register
			//to save last 4 keys user entered, store as 16-bit number
			if(checkDuration)
			begin
				case(keyHexIn)
					8'h69: begin
						durationAdded <= 4'd1;
						enterOut <= 1'b0;
						validDurKey <= ~validDurKey;
					end
					8'h72: begin
						durationAdded <= 4'd2;
						enterOut <= 1'b0;
						validDurKey <= ~validDurKey;
					end
					8'h7A: begin
						durationAdded <= 4'd3;
						enterOut <= 1'b0;
						validDurKey <= ~validDurKey;
					end
					8'h6B: begin
						durationAdded <= 4'd4;
						enterOut <= 1'b0;
						validDurKey <= ~validDurKey;
					end
					8'h73: begin
						durationAdded <= 4'd5;
						enterOut <= 1'b0;
						validDurKey <= ~validDurKey;
					end
					8'h74: begin
						durationAdded <= 4'd6;
						enterOut <= 1'b0;
						validDurKey <= ~validDurKey;
					end
					8'h6C: begin
						durationAdded <= 4'd7;
						enterOut <= 1'b0;
						validDurKey <= ~validDurKey;
					end
					8'h75: begin
						durationAdded <= 4'd8;
						enterOut <= 1'b0;
						validDurKey <= ~validDurKey;
					end
					8'h7D: begin
						durationAdded <= 4'd9;
						enterOut <= 1'b0;
						validDurKey <= ~validDurKey;
					end
					8'h70: begin
						durationAdded <= 4'd0;
						enterOut <= 1'b0;
						validDurKey <= ~validDurKey;
					end
					8'h5A: begin
						validDurKey <= 'b0;
						enterOut <= 1'b1;
					end
					default: begin
						validDurKey <= 'b0;
						enterOut <= 1'b0;
					end
				endcase
			end
			
			//select automatic mode. If key is erroneous, set autoSet to 0. 
			//PROCESS_IN remains waits until valid key pressed
			if(selectAuto) 
			begin
				case(keyHexIn)
					8'h4D: begin
						autoOut <= 3'b000;
						autoSet <= 1'b1;
					end
					8'h44: begin
						autoOut <= 3'b001;
						autoSet <= 1'b1;
					end
					8'h3A: begin
						autoOut <= 3'b010;
						autoSet <= 1'b1;
					end
					8'h2A: begin
						autoOut <= 3'b011;
						autoSet <= 1'b1;
					end
					8'h32: begin
						autoOut <= 3'b100;
						autoSet <= 1'b1;
					end
					8'h2D: begin
						autoOut <= 3'b101;
						autoSet <= 1'b1;
					end
					8'h23: begin
						autoOut <= 3'b110;
						autoSet <= 1'b1;
					end
					8'h1C: begin
						autoOut <= 3'b111;
						autoSet <= 1'b1;
					end
					default:begin
						autoOut <= 3'b000;
						autoSet <= 1'b0;
					end
				endcase
			end
			else
				autoSet <= 1'b0; //ensure that PROCESS_IN is not bypassed if valid keys pressed in other states
		end
	end
endmodule

module shiftRegister(reset,enable,parLoad,duration);
	input reset, enable;
	input [4:0] parLoad;
	output reg [15:0] duration;
	
	always@(posedge enable, posedge reset)
	begin
		if(reset)
			duration<= 'b0;
		else
		begin
			if(enable)
			begin
				duration[15:12] <= duration[11:8];
				duration[11:8] <= duration[7:4];
				duration[7:4] <= duration[3:0];
				duration[3:0] <= parLoad;
			end
		end
	end
endmodule
				
