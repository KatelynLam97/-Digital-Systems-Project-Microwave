module pwm_counter #(parameter NUM_BITS = 4) (clock, reset, enableC, oneSReset, fasterClock, parLoad,toggle,enable);
	input wire clock, reset, enableC, oneSReset, fasterClock;
	input wire [NUM_BITS-1:0] parLoad;
	reg [NUM_BITS-1:0] Q;
	reg numIterations;
	output wire enable;
	output wire toggle;
	
	toggle toggleOut(oneSReset, reset,toggle);
	compareOut #(.NUM_BITS(NUM_BITS))compare (clock, reset, enableC, Q, parLoad, enable);
	
	always@(posedge clock, posedge reset, posedge fasterClock)
	begin
		if(reset)
		begin
			Q <= 'b0;
		end
		else
		begin
			
			//at each pulse of 1s clock, start counter 
			if(fasterClock)
				Q <= 'b0;
			else
				Q <= Q +1;
			
		end
	end
endmodule


//controls PWM duty cycle by determining on-duration for every period
module compareOut #(parameter NUM_BITS = 4)(clock, reset, enableC, inLoad, parLoad, enable);
input clock, reset, enableC;
input [NUM_BITS-1:0] inLoad, parLoad;
output reg enable;

always@(posedge clock, posedge reset)
begin
	if(reset)
		enable <= 1'b0;
	else
	begin
		if((inLoad < (parLoad - 1)| (parLoad == 0 & parLoad == inLoad)) & enableC)
			enable <= 1'b1;
		else 
			enable <= 1'b0;
	end
end
endmodule 


module enableLatch(clock,reset,en,done,start,outEnable);
	input clock, reset, en, done,start;
	output reg outEnable;
	
	always@(posedge clock, posedge en, posedge done, posedge reset)
	begin
		if(en)
			outEnable <= 1'b1;
		else if(reset)
			outEnable <= 1'b0;
		else if(done)
			outEnable <= 1'b0;
		else if(!start)
			outEnable <= 1'b0;
	end
endmodule

//controls when the LED blinks on/off for each 1s iteration
module toggle(clock, reset, out);
	input clock, reset;
	output reg out;
	
	always@(posedge clock, posedge reset)
	begin
		if(reset)
			out <= 1'b0;
		else
			out <= ~out;
		//out <= 1'b1;
	end
endmodule