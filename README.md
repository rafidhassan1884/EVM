# Electronic Voting Machine
## Implemented Using FPGA Altera Flex10k

### Inputs and Outputs
In this EVM, there are in total 12 inputs. The inputs are- 
1.	Mode Switch – 1 DIP switch:
Can switch between voting mode and counting mode.
2.	Reset Switch – 1 DIP switch:
Toggling this switch we can reset the whole machine and its previously stored value
3.	Candidate buttons – 3 push Button:
In total there can be 3 candidates against whom vote can be casted.
4.	Authentication Button – 1 push Button: 
The authenticator can give permission to a voter to cast a vote by pressing this button.
5.	Checker button – 1 dip switch:
The checker button press checks whether the voter has already casted a vote or not. If the voter has not casted his vote yet one output led (named red_led) turns on.
6.	ID switches – 5 DIP switches:
The 5 dip switches are used to enter unique binary ID of each user. There can be total 32 users at max in the given 5 switch configuration.

Outputs of EVM:
1.	2 digit Seven Segment Displays.
2.	1 Green and 1 Red LED

![image](https://github.com/rafidhassan1884/EVM/assets/68016200/79f52f57-4388-45fb-ae2c-29561a1b2dcb)

### Operation of EVM:
Initially an authenticator starts the voting process by toggling the reset button and clearing the previous state of the machine. Next a voter starts the voting process by entering his/her unique binary ID which is 5 digit long in our case, in the ID switches. The authenticator then presses the checker button to check whether the voter has already voted or not. If the voter hasn’t already voted, a red led turns on. If all other things are okay and red led is on, the authenticator then presses the auth button which latches a register and turns on the green led. If the authenticator mistakenly presses the auth button even though the red led wasn’t on, the green led won’t turn on and the vote won’t be counted. So, this machine has a two-step verification system. 

As the green led is on, the voter can now cast his vote against one of the three candidates using the candidate button. As soon as one button is pressed, the authenticator register is latched to 0 and green led turns off. If the candidate now tries to cast a second vote, it will not be logged into the machine. That’s how we ensured one vote per voter at one go. Next voter can follow the same procedure repetitively.

When switched to counting mode, by switching the Mode Button, the result of the voting can be checked. Actually, the result can be checked at any point during the vote by toggling the Mode button. Pressing the button for each candidate we can see the no of votes received by that candidate whereas pressing the Auth button, total no of votes casted can be viewed.

### Function of Each modules:
1.	**buttonControl:**
This module registers the press of each candidate button and removes the debouncing effect and gives a register value = 1 as output if the button is pressed for a specific amount of time. The specific time setting can vary according to device as different devices has different debouncing properties.
2.	**authControl:**
This module does the same function as button control but for authority button. It considers whether red led is on for verification. If red led is off, the button press is not logged.  Separate module helps with later part of the code. 
3.	**ModeControl:**
Used for switching between voting and counting mode. It decides what will be done upon button press depending on the mode value from mode switch. 
4.	**Ver1:**
This module is verification block. It verifies whether the voter has voted before or not basing on the unique ID. If unique ID is okay, and voter has not voted before, it sets the red led. Then authenticator presses the auth button for permission. If red led = 1 and auth is pressed, it sets the green led and voter can proceed to vote.
5.	**Block:**
This is non standard block. The block takes votes from button control module and also from auth register (which is green led state) and spits out pulses that can be counted by vote logger if the votes are valid. Next, if one vote is casted by press of any candidate button, it checks the state of auth register and counts it as valid vote if auth reg is set otherwise ignores it. As soon as a valid vote registered this block sends a pulse to specific candidate vote logger for adding the vote and also resets the auth register to zero. 
6.	**VoteLogger:**
This module takes mode, valid votes from block module (the module that ensures only one valid vote is registerd by one voter) and logs the vote against respective candidates. 
7.	**Bin2bcd:**
This module converts the binary value of counted votes into BCD value. We need decimal value as separate digits to be displayed to the seven segment displays. That’s why this conversion is required.
8.	**Segment7:**
This is a BCD to seven segment display decoder. Default value is 0.
9.	**EVM:**
This module instantiates all the previous module and connects them in proper way to create a working Electronic Voting Machine

Please feel free to use this code and
help us improve this code by removing redundancy and improving readability.
