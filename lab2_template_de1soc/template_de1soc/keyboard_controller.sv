module keyboard_controller(clock, reset, pressed_key, direction, pause, restart);
	input logic clock, reset;
	input logic [7:0] pressed_key;
	output logic direction, pause, restart;
	logic [3:0] state;
	
	//key names and hex values
	parameter character_B = 8'h42;
	parameter character_D = 8'h44;
	parameter character_E = 8'h45;
	parameter character_F = 8'h46;
	parameter character_R = 8'h52;
	
	//state parameters
											 //3210
	parameter start = 				4'b1000;
	parameter forward_start = 		4'b0001;
	parameter forward_pause = 		4'b0011;
	parameter forward_restart = 	4'b1001;
	parameter backward_start = 	4'b0000;
	parameter backward_pause = 	4'b0010;
	parameter backward_restart = 	4'b1000;
	
	always_ff @(posedge clock or posedge reset) begin
		if (reset)
			state <= start;
		else
			begin
				case(state)
					start: if (pressed_key == character_E)							//wait until play key
									state <= forward_start;
							 else if (pressed_key == character_B)
									state <= backward_start;
							 else
									state <= start;
									
					forward_start: if (pressed_key == character_D)				//playing forward
											state <= forward_pause;
										else if (pressed_key == character_R)
											state <= forward_restart;
										else if (pressed_key == character_B)
											state <= backward_start;
										else
											state <= forward_start;
					
					forward_pause: if (pressed_key == character_E)				//pausing forward
											state <= forward_start;
										else if (pressed_key == character_R)
											state <= forward_restart;
										else if (pressed_key == character_B)
											state <= backward_pause;
										else
											state <= forward_pause;
					
					forward_restart:	state <= forward_start;						//restart forward
					
					backward_start: if (pressed_key == character_D)				//playing backward
											state <= backward_pause;
										 else if (pressed_key == character_R)
											state <= backward_restart;
										 else if (pressed_key == character_F)
											state <= forward_start;
										 else 
											state <= backward_start;
					
					backward_pause: if (pressed_key == character_E)				//pausing backward
											state <= backward_start;
										 else if (pressed_key == character_R)
										   state <= backward_restart;
										 else if (pressed_key == character_F)
											state <= forward_pause;
										 else
											state <= backward_pause;
					
					backward_restart:	state <= backward_start;				//restart backward
					
					default: state <= start;
				endcase
			end
	end

	//setting internal & output wires from states
	always_comb
	begin
		direction <= state[0];
		pause <= state[1];
		restart <= state[3];
	end

endmodule