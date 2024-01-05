/*Assignments
microwave
clock - CLOCK_50
reset - ~KEY[0]
modeSelect = SW[0]
keyboardEnter = enterOut (ledOut[0]) [PS2_Out] LEDR[0]
keyDuration = durationOut [PS2_Out], also output HEX5, HEX4
manualHeatLevel = SW[9:8]
manualStart = SW[1]
keyAutoChanged = autoSet(ledOut[1]) [PS2_Out] LEDR[1]
manualStop = ~KEY[1]
keyAutoMode = autoMode [PS2_Out]. Also output LEDR[5:3]
enDuration = durEnable (wire to PS2_out)
enHeatingLevel = heatLevelEnable (wire to PS2_out)
oMicrowaveClock = LEDR[9]
oPWM = LEDR[8]
oDone = LEDR[7]
currentState = HEX3

PS2_out
clock = CLOCK_50
reset = ~KEY[0]
checkLoadEnable = durEnable | heatLevelEnable (FSM control out)
selectAutoEn = SW[0]
durationOut = duration (HEX6, HEX5). NOTE displays 2 LSB.
autoMode = LEDR[5:3]
enterPressed = LEDR[0]
autoPressed = LEDR[1]
validKeyPressed = LEDR[2]

endDisplay
clock = CLOCK_50
enable = oDone (from microwave) also to LEDR[7]
reset = ~KEY[0]
hex2Out = HEX2
hex1Out = HEX1
hex0Out = HEX0
*/
module Microwave_Test2(CLOCK_50, SW, GPIO_0, PS2_CLK, PS2_DAT, KEY, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, LEDR, keyEntered, keyData);
input CLOCK_50;
input [9:0] SW;
input [1:0] KEY;

//ONLY IN SIM
input keyEntered;
input [7:0] keyData;

inout PS2_CLK;
inout PS2_DAT;

wire hundredMSClock, ps2_key_pressed, convertEnterOut, enterPressed, keyPressed, autoChanged, durEnable, heatLevelEnable, done;
wire pwmOut;
wire [15:0] duration, durationReg, countOutput;
wire [3:0] hexIn0, hexIn1, hexIn2, hexIn3, hexIn4, hexIn5;
wire [2:0] autoMode;

output[9:0] LEDR;
output[6:0] HEX5;
output[6:0] HEX4;
output[6:0] HEX3;
output[6:0] HEX2;
output[6:0] HEX1;
output[6:0] HEX0;
output [1:0] GPIO_0;

assign LEDR[0] = enterPressed;
assign LEDR[1] = autoChanged;
assign LEDR[2] = keyPressed;
assign LEDR[5:3] = autoMode;
assign LEDR[6] = durEnable;
//assign LEDR[3] = heatLevelEnable;
assign LEDR[7] = done;
assign LEDR[8] = pwmOut;
assign GPIO_0[0]= pwmOut;



//assign hexIn5 = duration[15:12];
//assign hexIn5 = duration[15:12];
//assign hexIn4 = duration[11:8];
//assign hexIn3 = duration[7:4];
//assign hexIn2 = duration[3:0];
//assign hexIn1 = ;
assign hexIn5 = countOutput[7:4];
assign hexIn4 = countOutput[3:0];
assign hexIn2 = duration[7:4];
assign hexIn1 = duration[3:0];
assign hexIn0 = 7'b0;

/*assign hexIn1 = duration[7:4];
assign hexIn0 = duration [3:0];*/

//cleans keyboardEnter to make sure it is not HIGH all the time
latchEnter latchEnter(hundredMSClock,ps2_key_pressed,convertEnterOut, enterPressed);
HundredMSCounter msCounter(CLOCK_50, ~KEY[0], 1'b1, hundredMSClock);


microwave microwaveOut(.clock(CLOCK_50),
							  .reset(~KEY[0]),
							  .modeSelect(SW[0]),
							  .keyboardEnter(enterPressed),
							  .keyUpdated(ps2_key_pressed),
							  .keyDuration(duration),
							  .manualHeatLevel(SW[9:8]),
							  .manualStart(SW[1]),
							  .keyAutoChanged(autoChanged),
							  .manualStop(~KEY[1]),
							  .keyAutoMode(autoMode),
							  .enDuration(durEnable),
							  .enHeatingLevel(heatLevelEnable),
							  .oMicrowaveClock(LEDR[9]),
							  .oPWM(pwmOut),
							  .motorSwitch(GPIO_0[1]),
							  .oDone(done),
							  .currentState(hexIn3),
							  .durationOut(durationReg),
							  .count(countOutput));
PS2_out keyLoad(	.clock(CLOCK_50), 
						.reset(~KEY[0] | done), 
						.checkLoadEn(heatLevelEnable), 
						.checkDurEn(durEnable),
						.selectAutoEn(SW[0]),
						.durationOut(duration),
						.autoMode(autoMode),
						.enterPressed(convertEnterOut),
						.autoPressed(autoChanged),
						.PS2_CLK(PS2_CLK),
						.PS2_DAT(PS2_DAT),
						.validKeyPressed(keyPressed),
						.ps2_key_pressed(ps2_key_pressed));

endDisplay displayEnd(.clock(CLOCK_50),
							 .enable(done),
							 .reset (~KEY[0]),
							 //.hexOut2(HEX2),
							 //.hex1Out(HEX1),
							 .hex0Out(HEX0));
							 
hex_decoder outHex5(.c(hexIn5),.display(HEX5), .enable(1'b1));
hex_decoder outHex4(.c(hexIn4),.display(HEX4), .enable(1'b1));
hex_decoder outHex3(.c(hexIn3),.display(HEX3), .enable(1'b1));
hex_decoder outHex2(.c(hexIn2),.display(HEX2), .enable(1'b1));
hex_decoder outHex1(.c(hexIn1),.display(HEX1), .enable(1'b1));
//hex_decoder outHex0(.c(hexIn0),.display(HEX0), .enable(1'b1));
/*hex_decoder outHex2(.c(hexIn2),.display(HEX2), .enable(done));
hex_decoder outHex1(.c(hexIn1),.display(HEX1), .enable(done));
hex_decoder outHex0(.c(hexIn0),.display(HEX0), .enable(done));*/

endmodule