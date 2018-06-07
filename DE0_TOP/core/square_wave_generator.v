
//---------------------------------------------------------------------------------
//-------------------- SQUARE WAVE GENERATOR --------------------------------------
//
// Generates a square wave signal based on the provided clock (50 MHz) with a 
// custom period (by setting the parameter PERIOD).
//
//
// Most important signals:
// 	* Parameters:
// 			* PERIOD 		- period in milliseconds.
// 	* Input signals:
//				* clock 			- clock signal (considered to have a frequency of 50 MHz).
//				* reset 			- asynchronus reset signal. 
// 	* Output Signals:
//				* wave 			- the square wave with the desired period.
//				* rising_edge 	- rising_edge of the square wave.
//----------------------------------------------------------------------------------

module SQUARE_WAVE_GENERATOR 
	#(
		// period in milliseconds
		parameter integer PERIOD = 500
	 )
	 (
		input wire clock,
		input wire reset,
		output wire wave,
		output wire rising_edge
	 );
	 
	 //=========================
	 // Constatns.
	 //=========================
	 
	 localparam COUNTER_VALUE = PERIOD * 50_000;
	 
	 
	 //=========================
	 // Signals.
	 //=========================
	 integer cnt_next = COUNTER_VALUE;
	 integer cnt_reg = COUNTER_VALUE;
	 reg active = 0;
	 
	 
	 
	 //=========================
	 // Program.
	 //=========================
	 
	 assign cnt_next = cnt_reg == 0? COUNTER_VALUE: cnt_reg - 1;
	 
	 assign wave = active;
	 
	 assign rising_edge = cnt_reg == 1;
	 
	 
	 always @(posedge clock, posedge reset)
	 begin
		if(reset == 1)
			cnt_reg = COUNTER_VALUE;
		else
			cnt_reg = cnt_next;
	 end
	 
endmodule	 
