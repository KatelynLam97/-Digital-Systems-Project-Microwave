/* Control module. Basic procedure for operation:
- Ensure START = 1 before loading inputs
SELECT Manual Mode: Enter duration, and heat level, pressing enter after every input
SELECT Auto Mode: Press appropriate key (see comment above)
- To stop microwave operation, press key STOP. Press STOP again to CLEAR, resume by pressing START
Refer to FSM diagram for more details.
*/
module control(clock, reset, selectMode, doneCount, load, start, startAuto, stop, newKeyPressed, keyDuration, autoMode, manualHeatLevel, 
			   enDuration, enHeatingLevel, enOut, enEnd,enReset, inDuration, inHeatLevel, stateReg);
	input wire clock, reset, selectMode, doneCount, load, start, startAuto, stop, newKeyPressed;
	input wire [15:0] keyDuration;
	input [2:0] autoMode;
	input wire [1:0] manualHeatLevel;
	wire waitDone;
	reg ackTime, ackHeat, ackWait, ackDone, waitEnable, potatoReg;
	reg [2:0] inAutoMode;
	reg [3:0] last_state, current_state, next_state, operating_state;
	output reg [15:0] inDuration;
	output reg [1:0] inHeatLevel;
	output reg enDuration, enHeatingLevel, enOut, enEnd, enReset;
	output wire [3:0]stateReg;
	
	assign stateReg = current_state;
	HundredMSCounter waitCounter(clock, waitEnable, 1'b1, waitDone);
	
	localparam  SET_MODE = 4'd0,
				INPUT_TIME = 4'd1,
				INPUT_TIME_WAIT = 4'd2,
				INPUT_HEAT_LEVEL = 4'd3,
				WAIT_START= 4'd4,
				MICROWAVE_OUT = 4'd5,
				PROCESS_IN = 4'd6,
				HIGH_30s = 4'd7,
				NORMAL_30s = 4'd8,
				MEDIUM_30s = 4'd9,
				LOW_30s = 4'd10,
				AUTO_RESET = 4'd11,
				CHECK_WAIT_DEBOUNCE = 4'd12,
				WAIT = 4'd13,
				DONE = 4'd14,
				CLEAR = 4'd15;
	
	 // Next state logic aka our state table
    always@(*)
    begin: state_table
            case (current_state)
				SET_MODE: begin
					if(start)
						next_state = selectMode ? PROCESS_IN : INPUT_TIME;
					else
						next_state = SET_MODE;
				end
				INPUT_TIME: begin
					next_state = load ? INPUT_TIME_WAIT : INPUT_TIME;
				end
				INPUT_TIME_WAIT: begin
					next_state = (!load & waitDone) ? INPUT_HEAT_LEVEL : INPUT_TIME_WAIT;
				end
				INPUT_HEAT_LEVEL: begin
					next_state = load ? WAIT_START : INPUT_HEAT_LEVEL;
				end
				WAIT_START: begin
					next_state = start & ackHeat ? MICROWAVE_OUT : WAIT_START;
				end
				MICROWAVE_OUT: begin
					if(doneCount)
						next_state = DONE;
					else if(stop)
						next_state = CHECK_WAIT_DEBOUNCE;
					else
						next_state = MICROWAVE_OUT;
				end
				PROCESS_IN: begin
					if(startAuto & newKeyPressed)
					begin
						if(autoMode == 3'b011 | autoMode == 3'b100)
							next_state = LOW_30s;
						else if(autoMode == 3'b110)
							next_state = MEDIUM_30s;
						else if(autoMode == 3'b111)
							next_state = NORMAL_30s;
						else
							next_state = HIGH_30s;
					end 
					else
						next_state <= PROCESS_IN;
			
				end
				HIGH_30s: begin
					if(stop)
						next_state = CHECK_WAIT_DEBOUNCE;
					else if(doneCount)
						next_state = AUTO_RESET;
					else
						next_state = HIGH_30s;
				end
				NORMAL_30s: begin
					if(stop)
						next_state = CHECK_WAIT_DEBOUNCE;
					else if(doneCount)
						next_state = AUTO_RESET;
					else
						next_state = NORMAL_30s;
				end
				MEDIUM_30s: begin
					if(stop)
						next_state = CHECK_WAIT_DEBOUNCE;
					else if(doneCount)
						next_state = AUTO_RESET;
					else
						next_state = MEDIUM_30s;
				end
				LOW_30s: begin
					if(stop)
						next_state = CHECK_WAIT_DEBOUNCE;
					else if(doneCount)
						next_state = AUTO_RESET;
					else
						next_state = LOW_30s;
				end
				AUTO_RESET: begin
					if(stop)
						next_state = WAIT;
					else
					begin
						case(last_state)
							HIGH_30s: begin
								if(autoMode == 3'b001 & !potatoReg | autoMode == 3'b010 | autoMode == 3'b101)
									next_state = NORMAL_30s;
								else if((autoMode == 3'b001 & potatoReg) | autoMode == 3'b000)
									next_state = DONE;
							end
							NORMAL_30s: begin
								if(autoMode == 3'b001)
									next_state = HIGH_30s;
								else if(autoMode == 3'b010 |autoMode == 3'b101| autoMode == 3'b111)
									next_state = DONE;
								else
									next_state = NORMAL_30s;
							end 
							MEDIUM_30s: begin
								if(autoMode == 3'b011 | autoMode == 3'b110)
									next_state = DONE;
								else
									next_state = MEDIUM_30s;
							end 
							LOW_30s: begin
								if(autoMode == 3'b011)
									next_state = MEDIUM_30s;
								else if(autoMode == 3'b100)
									next_state = DONE;
								else
									next_state = LOW_30s;
							end
							default:
								next_state = AUTO_RESET;
						
						endcase
					end
				end
				
				CHECK_WAIT_DEBOUNCE: begin
					next_state = (stop & !waitDone) ? CHECK_WAIT_DEBOUNCE: WAIT;
				end			
				
				WAIT: begin
					if(stop)
						next_state = CLEAR;
					else if(start)
						next_state = operating_state;
					else
						next_state = WAIT;
				end
				
				DONE: begin
					next_state = start ? DONE : CLEAR;
				end
				CLEAR: begin
					next_state = SET_MODE;
					//next_state = (ackWait == 1'b1 | ackDone == 1'b1)? SET_MODE : WAIT;
				end
            default:     next_state = SET_MODE;
        endcase
    end // state_table
	
	    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
		enDuration <= 1'b0;
		enHeatingLevel <= 1'b0;
		enOut <= 1'b0;
		enEnd <= 1'b0;
		enReset	<= 1'b0;
		waitEnable <= 1'b0;
		//potatoReg <= 1'b0;

        case (current_state)
			INPUT_TIME: begin
				enDuration <= 1'b1;
				inDuration <= keyDuration;
				waitEnable <=1'b1;
				ackTime <= 1'b1;
			end 
			INPUT_TIME_WAIT: begin
				enHeatingLevel <= 1'b1;
				//enterReg <= 1'b0;
				
			end
			INPUT_HEAT_LEVEL: begin
				enHeatingLevel <= 1'b1;
				inHeatLevel <= manualHeatLevel;
				waitEnable <= 1'b1;
				ackTime <= 1'b0;
				ackHeat <= 1'b1;
			end 
			MICROWAVE_OUT: begin
				enOut <= 1'b1;
				operating_state <= MICROWAVE_OUT;
			end
			PROCESS_IN: begin
				//autoMode <= autoMode;
				potatoReg <= 1'b0;
				//enOut <= 1'b1;
			end 
			HIGH_30s: begin
				enHeatingLevel <= 1'b1;
				inHeatLevel <= 2'b11;
				operating_state <= HIGH_30s;
				
				enDuration <= 1'b1;
				if(autoMode == 3'b000 || autoMode == 3'b001)
				begin
					inDuration <= 16'd10;
				end
				else if(autoMode == 3'b010)
					inDuration <= 16'd20;
				else
					inDuration <= 16'd5;
					
				enOut <= 1'b1;
			end
			NORMAL_30s: begin
				enHeatingLevel <= 1'b1;
				inHeatLevel <= 2'b10;
				if(autoMode == 3'b001)
					potatoReg <= 1'b1;
				operating_state <= NORMAL_30s;
				enDuration <= 1'b1;
				if(autoMode == 3'b011)
					inDuration <= 16'd10;
				else if(autoMode == 3'b101)
					inDuration <= 16'd20;
				else
					inDuration <= 16'd5;
					
				enOut <= 1'b1;
			end
			MEDIUM_30s: begin
				enHeatingLevel <= 1'b1;
				inHeatLevel <= 2'b01;
				operating_state <= MEDIUM_30s;
				enDuration <= 1'b1;
				if(autoMode == 3'b110)
					inDuration <= 16'd30;
				else
					inDuration <= 16'd5;
					
				enOut <= 1'b1;
			end
			LOW_30s: begin
				enHeatingLevel <= 1'b1;
				inHeatLevel <= 2'b00;
				operating_state <= LOW_30s;
				enDuration <= 1'b1;
				if(autoMode == 3'b011)
					inDuration <= 16'd15;
				else
					inDuration <= 16'd5;
					
				enOut <= 1'b1;
			end
			AUTO_RESET : begin
				enReset <= 1'b1;
			end
			CHECK_WAIT_DEBOUNCE : begin
				waitEnable <= 1'b1;
			end
			WAIT : begin
				waitEnable <= 1'b1;
				ackWait <= 1'b1;
				ackDone <= 1'b0;
			end
			DONE: begin
				enEnd <= 1'b1;
				ackDone <= 1'b1;
				ackWait <= 1'b0;
			end 
			CLEAR: begin
				enReset <= 1'b1;
				inDuration <= 1'b0;
				inHeatLevel <= 1'b0;
				ackWait <= 1'b0;
				ackDone <= 1'b0;
			end
				
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals

    // current_state registers
    always@(posedge clock)
    begin: state_FFs
        if(reset)
            current_state <= SET_MODE;
        else
		begin
			if(current_state != WAIT)
				last_state <= current_state;
          current_state <= next_state;
		end
    end // state_FFS
endmodule