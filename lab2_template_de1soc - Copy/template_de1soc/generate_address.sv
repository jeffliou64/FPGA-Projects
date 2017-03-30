module generate_address (clk, reset, address_en, direction, address_ready, address_out);

input clk, reset,
address_en,                          //from main finist state machine, also in get_address, allows address to be sent to the output
direction;                           //1 for forward direction, 0 for backward direction
output address_ready;                //feeds to finite state machine, tells whether address is ready to read
output logic [22:0] address_out;

logic [2:0] state;
logic [22:0] next_address;
logic send, next;

//parametrizing addresses
parameter starting_address = 23'h0;
parameter ending_address = 23'h7ffff;

//parametrizing states
parameter idle = 3'b000;
parameter send_address = 3'b010;
parameter count = 3'b001;
parameter ready = 3'b100;

//assigning outputs
assign next = state[0];
assign send = state[1];
assign address_ready = state[2];

//finite state machine for address counter
    always_ff @(posedge clk, posedge reset) begin
        if(reset)
            state = idle;                        //state turns to idle on positive edge of reset
        else
            case (state)                         //checking multiple cases for the states fir different inputs
                idle: if (address_en)
                        state <= send_address;   //for address_en state changes to send_address
                            else
                        state <= idle;
            send_address : state <= count;       //state changes from send_address to count

            count: state <= ready;               //state changes from count to readt

            ready: state <= idle;                //state changes from ready to idle

        endcase                                  //ending case statement
    end                                          //ending always block


    //executed whn in the send_address state i.e. when send is asserted
    always_ff @(posedge send)
        address_out <= next_address;

    //executed in the state; counter. I.e. when next is asserted
    always_ff @(posedge next, posedge reset) begin
	  if (reset)
			next_address <= starting_address;

			else if (direction)                        //if the address is moving forward, begin
			begin
				 if (address_out == ending_address)
					 next_address <= starting_address;   //if we reach the last address, we go back to the startinf address

				 else
					  next_address <= next_address + 1;  //if we havent reached the lsat address we keep going to next address
			end
			
			else if (!direction) begin                  //if the address is moving back wards
				 if (address_out == starting_address)
								 next_address <= ending_address;
				 else
								 next_address <= next_address - 1;
			end
	  end                                             //ending always block
endmodule                                            //ending module

