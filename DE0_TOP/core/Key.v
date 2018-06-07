
//---------------------------------------------------------------------------------
//--------------------------------- KEY ---------------------------------
//
// Module used for registering the press of a key.
//
//
// Most important signals:
//		* Parameters:
//				* KEY_CODE		- the key code the module listents to.
// 	* Input signals:
//				* clock 			- clock signal (considered to have a frequency of 50 MHz).
//				* reset 			- asynchronus reset signal. 
//				* current_code	- the current key code.
// 	* Output Signals:
//				* value 	- indicates if the key is pressed.
//----------------------------------------------------------------------------------

`include "./constants.vh"

module Key
		#(
			parameter KEY_CODE
		)
		(
			input wire clock,
			input wire reset,
			input wire [7:0] current_code,
			output wire value
		);
		
		//=====================
		// Constatnts.
		//=====================
		
		// States. 
		localparam OFF		= 0;
		localparam ON 		= 1;
		localparam TERM   = 2;
		
		//=====================
		// Signals.
		//=====================

		integer state_reg, state_next; 

		//=====================
		// Program.
		//=====================	
	
		assign value = state_reg == ON || state_reg == TERM;	
		
		always @(posedge clock, posedge reset)
		begin
			if(reset)
				begin
					state_reg = OFF;
				end
			else
				begin
					state_reg = state_next;
				end
		end
		

		always @(current_code)
		begin
			state_next = state_reg;
		
			case (state_reg)
			
			OFF:
				if(current_code == KEY_CODE)
					state_next = ON;
			ON:
				if(current_code == TERMINATE)
					state_next = TERM;
			TERM:
				if(current_code == KEY_CODE)
					state_next = OFF;
				else 
					if(current_code == TERMINATE || current_code == DUMMY)
						state_next = TERM;
					else
						state_next = ON;
			endcase
		end
		
endmodule