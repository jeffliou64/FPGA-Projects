module lab4_top(CLOCK_50, 
				KEY,	
				LEDR);

//inputs and outputs
input CLOCK_50;
input [3:0] KEY;
output logic [9:0] LEDR;
//output logic [6:0] HEX0;
//output logic [6:0] HEX1;
//output logic [6:0] HEX2;
//output logic [6:0] HEX3;
//output logic [6:0] HEX4;
//output logic [6:0] HEX5;

//logic [7:0] address, data, q; // S signals
//logic [7:0] address_encr, q_encr; // encrypted memory signals
//logic [7:0] address_decr, data_decr, q_decr; // decrypted memory signals
//logic wren, wren_decr;
//logic [31:0] decrypted_message1;
//logic decrypted_success_flag1;
//logic enable1;

//assign decrypted_success_flag1 = 1'b0;
//assign enable1 = 1'b1;
//s_memory S(address, CLOCK_50, data, wren, q);
//e_memory E(address_encr, CLOCK_50, q_encr);
//d_memory D(address_decr, CLOCK_50, data_decr, wren_decr, q_decr);

//instantiating each ksa core, with a given range of keys to look for
//speeds up key search by X times (X = number of cores)
ksa ksa1(.CLOCK_50(CLOCK_50), 
				.KEY(KEY),
				.keymin(24'b0),
				.keymax(1048575));
				
ksa ksa2(.CLOCK_50(CLOCK_50), 
				.KEY(KEY),
				.keymin(1048576),
				.keymax(2097152));
				
ksa ksa3(.CLOCK_50(CLOCK_50), 
				.KEY(KEY),
				.keymin(2097153),
				.keymax(3145727));
				
ksa ksa4(.CLOCK_50(CLOCK_50), 
				.KEY(KEY),
				.keymin(3145728),
				.keymax(4194303));

//always_comb
//begin
//	if (decrypted_success_flag1 == 1'b1)
//	begin
//		enable1 <= 1'b0;
//	end
//	else
//	begin
//		enable1 <= 1'b1;
//	end
//end

endmodule