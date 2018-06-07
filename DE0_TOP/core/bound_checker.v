
//---------------------------------------------------------------------------------
//--------------------------------- BOUND CHECKER ---------------------------------
//
// Checks if the value is in valid state
//
//
// Most important signals:
// 	* Input signals:
//				* value 	- the value that will be tested.
//				* max 	- the max value.
//				* min 	- the min value.
// 	* Output Signals:
//				* valid 	- indicates if the signal is in valid state.
//				* snap	- if out of bounds, the value that should be assigned to value to remain.
//----------------------------------------------------------------------------------

module BOUND_CHECKER 
			(
				input integer value,
				input integer min,
				input integer max,
				output wire valid,
				output integer snap
			);
	
	// Indicates if the state is valid.
	assign valid = value >= min && value <= max;
	
	// The closet bound to which the input
	// should snap in order to remain valid.
	assign snap = (value <= min ) ? min : max; 
			
endmodule