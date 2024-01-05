# -Digital-Systems-Project-Microwave

## 1.0 Specifications
+	Create a microwave controller that can cook food, either through manual or automatic settings, at a certain heat level and duration of time
+	The user should either:
  
  - Manually configure the cooking operation: Input the amount of time they want to cook the food for by typing in the num pad. The maximum allowed time is 99:99 (99 min and 99s )
  - Use heat level switches to select one of the following heat levels:
    - LOW: 10% duty cycle
    - MEDIUM: 30% duty cycle
    - NORMAL: 50% duty cycle
    - HIGH: 80% duty cycle
      
  - Automatic selection for the following cooking functions with the following specifications:
    - Popcorn: cooks at HIGH for 1:00 mins
    - Potato – cooks at HIGH for 1:00 mins, cooks at NORMAL for 30s, then HIGH for 1:00 min
    - Meat – cooks at HIGH for 2:00 mins, then cooks at NORMAL for 1:00 mins
    - Veggies – cooks at LOW for 1:30 mins, then MEDIUM for 30s
    - Beverage – cooks at LOW for 30s
    - Reheat – cooks at HIGH for 30s, then cooks at NORMAL for 2:00 mins
    - Defrost – cooks at MEDIUM for 3:00 mins
    - Auto – cooks at NORMAL heat level for 1:30 mins
      
+	The user must toggle the switch to START before the cooking operation starts. If they want to change a configuration, they must toggle the switch to STOP first
+	The VGA must display the control panel as shown in Section 1.1. 
   - The timer should update and start counting down from the duration of operation after START is pressed
   - When the corresponding input button is pressed on the keyboard, the display button should flip to a “pressed” graphic for 0.5s to simulate clicking
+	When the cooking operation is finished, “end” should be displayed in the VGA and the 7-segment display.
  
## 2.0  Inputs
+	Start/Stop Switch: Off position indicates stop, on position indicates start
+	Switch for manual/automatic mode
+	Keyboard: used to indicate cook modes/duration
  - Numpad: used to input duration of microwave operation
  - Microwave Functions
    - p - popcorn
    - o – potato
    - m – meat
    - v – veggies 
    - b - beverage
    - r – reheat
    - d – defrost
    - a – auto
+ Heating level switches (2): Select heating level based on the following switch inputs:
  - 00: LOW
  - 01: MEDIUM
  - 10: NORMAL
  - 11: HIGH
    
## 3.0 Outputs
+	Motor: simulates microwave heating operation
+	VGA display
  - Displays control panel for the microwave
+	7-seg display (3): displays “end” when microwave has finished cooking
