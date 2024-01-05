
module PS2_out (
	// Inputs
	clock,
	reset,
	checkLoadEn,
	checkDurEn,
	selectAutoEn, //connect to selectMode

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	// Outputs
	durationOut,
	autoMode,
	enterPressed,
	autoPressed,
	validKeyPressed,
	ps2_key_pressed
	
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input clock, reset, checkLoadEn, checkDurEn, selectAutoEn;

// Bidirectionals
inout				PS2_CLK;
inout				PS2_DAT;

// Outputs
output wire enterPressed,autoPressed,validKeyPressed;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire		[7:0]	ps2_key_data;
output wire				ps2_key_pressed;

// Internal Registers
reg			[7:0]	last_data_received;

output wire [2:0] autoMode;
output wire [15:0] durationOut;


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/
													
always @(posedge clock)
begin
	if (reset == 1'b0)
		last_data_received <= 8'h00;
	else if (ps2_key_pressed == 1'b1)
		last_data_received <= ps2_key_data;
		
		
end

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
 keyboardConvertIn2 keyboardConverter(
										.reset(reset),
										.keyIn(ps2_key_pressed), 
									   .keyHexIn(ps2_key_data), 
									   .checkLoad(checkLoadEn), 
									   .checkDuration(checkDurEn), 
									   .selectAuto(selectAutoEn),
									   .enterOut(enterPressed),
									   .durationOut(durationOut),
									   .autoOut(autoMode),
									   .autoSet(autoPressed),
									   .validDurKey(validKeyPressed));

PS2_Controller PS2 (
	// Inputs
	.CLOCK_50			(clock),
	.reset				(reset),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);
endmodule
