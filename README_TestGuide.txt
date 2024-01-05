Test Guide

Top Level Module: Microwave_Test1
I. Pin Assignments
KEY[0] - Reset
KEY[1] - Stop

SW[0] - select mode (off selects MANUAL, on selects AUTO)
SW[1] - start
SW[9:8] - select heat level (00 - LOW, 01 - MEDIUM, 10 - NORMAL, 11 - HIGH)

LEDR[0] - keyboard enter. HIGH when enter is pressed.
LEDR[1] - automatic mode selected. HIGH when one of the valid auto keys are pressed.
LEDR[2] - outputs HIGH when valid key pressed (see Specifications)
LEDR[7] - outputs HIGH when a microwave sequence has completed
LEDR[8] - outputs PWM signal corresponding to "cooking"
LEDR[9] - outputs 1s pulse while "cooking"

HEX2:HEX0 - End display. Displays "End" when microwave sequence has finished
HEX3 - Displays current state of FSM to help with debugging. There are 135 states (refer to control.v)
HEX4:HEX5 - Displays LSB of duration. In lab try to test 2 digit inputs just to save time.


Notes: No need to worry about KEY being Active HIGH. We inverted the input in the code.

II. Guide to Operation
	1. Press KEY[0] to reset all states
	2. Toggle SW[0] to desired mode
	3. Toggle SW[1] to the on position
	
	MANUAL Mode
	a. Use the numpad of the keyboard to enter duration. Press enter.
	b. Select heat level using SW[9:8]. Press enter.
	
	AUTO Mode
	a. Press a valid key on the keyboard (p,o,m,v,b,r,d,a).
	
	3. Microwave outputs PWM signal and 1s pulse
	4. Microwave end screen displayed HEX2 - HEX0 blinks "End" until toggle SW[1] to off position.
	
	STOPPING IN THE MIDDLE
	- To stop in the middle, while the microwave is operating toggle SW[1] to off position.
	- Press KEY[1] to stop
	- Toggle SW[1] to on position to resume
	- Press KEY[1] again to clear and restart. Ensure that before making your selection toggle SW[1] to on again.
	
III. Possible Problems
	1. When stopping in the middle, during the WAIT state it might go to CLEAR because of debounce
	2. There may be a delay if stopping while an auto state is transitioning 
	
	(Actual)
	- Skipped state 3 due to debounce. Add additional state. Try to do key_pressed
	- End display is s upposed to be nothing in the beginning

MODEL SIM WORKING BEFORE TEST ON SAT. Fixed problems above in SIM.
- Test PWM with a higher clock frequency
- Motor if time allows
	

