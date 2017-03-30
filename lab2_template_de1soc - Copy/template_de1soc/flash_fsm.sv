module flash_fsm (clock50MHZ, clock22KHZ, read_valid, wait_request, reset, pause, direction, read_data, read, byte_enable, data_out, address);
	
	//inputs and outputs
	input logic clock50MHZ, clock22KHZ, read_valid, wait_request, reset, pause, direction;
	input logic [31:0] read_data;
	output logic read;
	output logic [3:0] byte_enable;
	output logic [15:0] data_out;
	output logic [22:0] address;
	
	//creating internal wires
	logic address_enable;
	logic address_ready;
	logic low_data_valid;
	logic high_data_valid;
	logic [11:0] state;
	
	//state parameters
										   //2198_7654_3210     eight bytes for generate_address inputs, 4 bytes to differentiate similar state values
	parameter idle =				 12'b1000_0000_0000;	//resting state
	
	parameter checkvalidlow =	 12'b0000_0110_1111;	//reads lower bytes of address
	parameter checkvalidhigh =  12'b0000_1010_1111;	//reads upper bytes of address
	
	parameter clock_22_low1 =	 12'b0010_0000_0000;	//waits until clock22KHZ is off
	parameter clock_22_high1 =	 12'b0011_0000_0000;	//waits until posedge clock22KHZ for lower byte read
	
	parameter clock_22_low2 = 	 12'b0100_0000_0000;	//waits until clock22KHZ is off
	parameter clock_22_high2 =	 12'b0101_0000_0000;	//waits until posedge clock22KHZ for upper byte read
	
	parameter get_address = 	 12'b0000_0001_0000;	//turns on address_enable, allows generate_address() to get an address
	parameter off_address =		 12'b0001_0000_0000;	//turns off address_enable, stops generate_address() until ready for next one
	
	//assigning the output wires from the states
	//assign high_data_valid = state[7];	
	//assign low_data_valid = state[6];	
	//assign read = state[5];		
	//assign address_enable = state[4];
	//assign byte_enable = {state [3:0]};
	
	//calling generate_address to get the next address
	generate_address get_add(
		.clk(clock50MHZ),
		.reset(reset),
		.address_en(address_enable),
		.direction(direction),
		.address_ready(address_ready),
		.address_out(address)
	);
	
	always_ff @ (posedge clock50MHZ or posedge reset) begin
		if (reset) state <= idle;
		else begin
			case (state)
				idle: 			if (pause) 				state <= idle;					//stops here if there is a pause
									else 		  				state <= get_address;		//else moves to next state
				
				get_address: 								state <= off_address;		//turns on the address_enable for one cycle
				
				off_address: 	if (address_ready) 	state <= checkvalidlow;		//turns off address_enable and waits until a valid address is retrieved
									else						state <= off_address;
						 
				checkvalidlow: if (read_valid)	 	state <= clock_22_low1; 	//checks that the data at address is valid
									else					 	state <= checkvalidlow;		//
								 
				clock_22_low1: if (!clock22KHZ)   	state <= clock_22_high1;	//we want to wait until the next posedge of the 22KHZ clock (syncing clocks)
									else				    	state <= clock_22_low1;		//waits until clock is low if already high
								  
				clock_22_high1: if (clock22KHZ)   	state <= checkvalidhigh;	//wait until the next posedge of 22KHZ clock
									 else				    	state <= clock_22_high1;	//
				
				checkvalidhigh: if (read_valid) 	 	state <= clock_22_low2;		//finished getting lower half of data, now checking upper bytes of data for validity
									 else 				   state <= checkvalidhigh;	//
				
				clock_22_low2: if (!clock22KHZ) 	 	state <= clock_22_high2;	//syncing clocks for the high bytes
									else				    	state <= clock_22_low2;		//
								  
				clock_22_high2: if (clock22KHZ)   	state <= idle;					//
									 else				    	state <= clock_22_high2;	//
				
				default: state <= idle;														//default statement
			endcase
		end
	end
	
	//output logic
	//wait until the datatoread is valid, then sends it to output
	always_ff @(posedge read_valid) begin
		if (low_data_valid)
			data_out <= read_data[15:0];
		else if (high_data_valid)
			data_out <= read_data[31:16];
	end
	
	//setting internal & output wires from states
	always_comb begin
		high_data_valid <= state[7];	
		low_data_valid <= state[6];	
		read <= state[5];		
		address_enable <= state[4];
		byte_enable <= {state [3:0]};
	end
		
endmodule