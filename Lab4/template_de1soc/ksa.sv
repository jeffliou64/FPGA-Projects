module ksa(CLOCK_50,
                KEY,
					 LEDR,
					 HEX0,
					 HEX1,
					 HEX2,
					 HEX3,
					 HEX4,
					 HEX5);

//inputs and outputs
input CLOCK_50;
input [3:0] KEY;
//input [23:0] keymin, keymax;
output logic [9:0] LEDR;
output logic [6:0] HEX0;
output logic [6:0] HEX1;
output logic [6:0] HEX2;
output logic [6:0] HEX3;
output logic [6:0] HEX4;
output logic [6:0] HEX5;

// states
logic [4:0] state;
parameter init 						= 5'b0_0000;
parameter fill_S_memory 			= 5'b0_0001;
parameter read_SI1 					= 5'b0_0010;
parameter SI_read_delay 			= 5'b0_0011;
parameter read_SI2 					= 5'b0_0100;
parameter set_J1 						= 5'b0_0101;
parameter set_J2 						= 5'b0_0110;
parameter read_SJ1 					= 5'b0_0111;
parameter SJ_read_delay 			= 5'b0_1000;
parameter read_SJ2 					= 5'b0_1001;
parameter swap_SI 					= 5'b0_1010;
parameter swap_SJ 					= 5'b0_1011;
parameter wait_a_cycle 				= 5'b0_1100;
parameter swap1_done 				= 5'b0_1101;
parameter swap2_done 				= 5'b0_1110;
parameter reset_all 					= 5'b0_1111;
parameter set_read_SI1 				= 5'b1_0000;
parameter set_SI_read_delay 		= 5'b1_0001;
parameter set_read_SI2 				= 5'b1_0010;
parameter read_SF1			 		= 5'b1_0011;
parameter SF_read_delay 			= 5'b1_0100;
parameter read_SF2 					= 5'b1_0101;
parameter decrypt1 					= 5'b1_0110;
parameter decrypt_delay 			= 5'b1_0111;
parameter decrypt2 					= 5'b1_1000;
parameter decrypt3 					= 5'b1_1001;
parameter check_decrypt 			= 5'b1_1010;
parameter increment_key 			= 5'b1_1011;
parameter read_decryption 			= 5'b1_1100;
parameter read_decrypt_delay 		= 5'b1_1101;
parameter decryption_successful 	= 5'b1_1110;
parameter decryption_failed 		= 5'b1_1111;

// memory signals
logic [7:0] address, data, q; // s memory signals
logic [7:0] encrypted_address, encrypted_q; // encrypted memory signals
logic [7:0] decrypted_address, decrypted_data, decrypted_q; // decrypted memory signals
logic wren, decrypted_wren;

// internal signals
logic [31:0] i, j, k, f;
logic [31:0] Si_value, Sj_value, Sf_value, encrypt_k, decrypt_k;
byte  secret_key [3];
logic [23:0] secret_key_24_bit;
logic decrypt_success, decrypt_failed;

//instantiate memorys
s_memory S(address, CLOCK_50, data, wren, q);
e_memory E(encrypted_address, CLOCK_50, encrypted_q);
d_memory D(decrypted_address, CLOCK_50, decrypted_data, decrypted_wren, decrypted_q);

//display secret key on HEX
SevenSegmentDisplayDecoder SevenSegmentDisplayDecoder_inst0(.ssOut(HEX0), .nIn(secret_key_24_bit[3:0]));
SevenSegmentDisplayDecoder SevenSegmentDisplayDecoder_inst1(.ssOut(HEX1), .nIn(secret_key_24_bit[7:4]));
SevenSegmentDisplayDecoder SevenSegmentDisplayDecoder_inst2(.ssOut(HEX2), .nIn(secret_key_24_bit[11:8]));
SevenSegmentDisplayDecoder SevenSegmentDisplayDecoder_inst3(.ssOut(HEX3), .nIn(secret_key_24_bit[15:12]));
SevenSegmentDisplayDecoder SevenSegmentDisplayDecoder_inst4(.ssOut(HEX4), .nIn(secret_key_24_bit[19:16]));
SevenSegmentDisplayDecoder SevenSegmentDisplayDecoder_inst5(.ssOut(HEX5), .nIn(secret_key_24_bit[23:20]));

// MAIN
always_ff @(posedge CLOCK_50)										//always on the positive edge of the clock 
    begin

    if(KEY[0] == 0) begin											//if KEY[0] has the value 0, begin      
        {i,j,k,f,Si_value,Sj_value,decrypt_success,decrypt_failed} <= {32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,1'b0,1'b0};
        secret_key_24_bit <= 24'b0;
        secret_key[0] <= 8'd0;                           //initializing first part of secret key
        secret_key[1] <= 8'd0;                           //initializing second part of secret key
        secret_key[2] <= 8'd0;                           //initializing third part of secret key
        state <= init;
    end
    else begin															//if KEY[0] is not equal to 0, begin  
        case (state)
            init:														//initializing the fill loop   
                begin
                    // initializing values
                    {i,j,k,f,Si_value,Sj_value,decrypt_success,decrypt_failed} <= {32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,1'b0,1'b0};
                    secret_key_24_bit <= 24'b0;
                    secret_key[0] <= 8'd0;
                    secret_key[1] <= 8'd0;
                    secret_key[2] <= 8'd0;
                    state <= fill_S_memory;
                end

            //increments the 24-bit key
            increment_key:
                begin
                    secret_key_24_bit = {secret_key[0], secret_key[1], secret_key[2]};    //over key (24 bits) gets values from 3 8-bits keys
                    secret_key_24_bit = secret_key_24_bit + 1'b1;                         //adding another bit to the 24 bit key

                    secret_key[0] <= {2'b00, secret_key_24_bit[21:16]};                   //the first sub key gets 2 0-bits and 6 bits from the big key
                    secret_key[1] <= secret_key_24_bit[15:8];                             //the second sub key gets the 8 middle bits from the big key
                    secret_key[2] <= secret_key_24_bit[7:0];                              //the third sb key gets the lowest 8 bits from the big key


                    if ( secret_key_24_bit > keymax ) state <= decryption_failed;         //if secret key is bigger than the max, the decryption has failed
                    else state <= fill_S_memory;                                            //otherwise state goes to fill s memory
                end

            fill_S_memory:                                                                  //for the state fill_S_memory begin
                begin
                    // fill_S_memory memory
                    address <= i;                                                         //address gets the value of i similar to the one from the C code provided
                    data <= i;                                                            //data gets the value of i as well
                    wren <= 1'b1;                                                         //wren gets the value of 1 bit
                    i <= i + 1;                                                           //i is incremented

                    // if the memory is full, move to done state, otherwise stay in fill_memory
                    if( i > 255 ) begin                                                   //if i gets greater than 255 begin
                        i <= 0;                                                           //i is reset to 0
                        state <= read_SI1;                                                //state becomes read_ST1
                    end
                    else state <= fill_S_memory;                                          //if i is less than 256, state goes back to fill memory
                end

            read_SI1:													
                begin
                    address <= i;
                    wren <= 1'b0;									//gets S[i] i address
                    state <= SI_read_delay;
                end

            SI_read_delay:
                begin
                    state <= read_SI2;								//wait a cycle to read S[i]
                end

            read_SI2:
                begin
                    Si_value <= q;									// get value of S[i]
                    state <= set_J1;
                end

            set_J1:
                begin
                    j <= (j + Si_value + secret_key[i % 3]) % 256; // j = (j + s[i] + secret_key[i mod keylength] ) mod 256 //keylength is 3 in our impl.
                    state <= read_SJ1;
                end

            read_SJ1:
                begin
                    address <= j;                    			//gets S[j] j address
                    wren <= 1'b0;
                    state <= SJ_read_delay;
                end

            SJ_read_delay:
                begin
                    state <= read_SJ2;					  			//wait a cycle to read S[j]
                end

            read_SJ2:
                begin
                    Sj_value <= q;									//get value of S[j]
                    state <= swap_SJ;
                end
				
				//swapping S[i] and S[j]
				//put SJ_value into S[i]
            swap_SJ:
                begin
                    address <= i;									//set address to current value of i
                    data <= Sj_value;								//set data to be value in S[J]
                    wren <= 1'b1;		

                    if(i == 0) state <= wait_a_cycle;			//creating a delay between swaps
                    else state <= swap_SI;
                end
					 
				//one clock cycle delay before swapping
				wait_a_cycle:
                begin
                    state <= swap_SI;
                end
					 
				//putting SI_value into S[j]
            swap_SI:
                begin
                    if ( k == 0 )
                        begin
                            address <= j;							//set address to current value of j
                            data <= Si_value;					//set data to be value in S[I]
                            wren <= 1'b1;			
									 i = i + 1;								// increment I for next loop

                            if ( i > 255 ) state <= reset_all;
                            else state <= read_SI1; 			//finished with 1st swap
                        end
                    else if ( k >= 1 )								//in 2nd swap
                        begin
                            address <= j;							//same as above
                            data <= Si_value;
                            wren <= 1'b1;
                            state <= swap2_done;  				// finished with 2nd swap
                        end
                end

            reset_all: //done with 1st swap, prepping for all swaps after 1st swap
                begin
                    // k gets set to 1 so that the swap states know that we are in the second swap
                    {i,j,k,f} <= {32'b0,32'b0,32'b0000_0000_0000_0000_0000_0000_0000_0001,32'b0};
                    state <= set_read_SI1;
                end

            //S[]
            set_read_SI1:
                begin
                    i = (i + 1) % 256;								//(i + 1) mod 256
                    address <= i;									//set address to i
                    wren <= 1'b0;
                    state <= set_SI_read_delay;
                end

            set_SI_read_delay:
                begin
                    state <= set_read_SI2;						// wait a cycle
                end

            set_read_SI2:
                begin
                    Si_value <= q;									// get value of s[i] from memory
                    state <= set_J2;
                end

            set_J2:
                begin
                    j <= (j + Si_value) % 256;					//(j + S[i]) mod 256
                    state <= read_SJ1;
                end

            swap2_done:
                begin
                    f <= (Si_value + Sj_value) % 256;			//f = s[ (s[i]+s[j]) ]
                    state <= read_SF1;
                end

            read_SF1:
                begin
                    address <= f;									//set address to f
                    wren <= 1'b0;							
                    state <= SF_read_delay;
                end

            SF_read_delay:
                begin
                    state <= read_SF2;								//wait a cycle to read
                end

            read_SF2:
                begin
                    Sf_value <= q;									// get value of s[f]
                    state <= decrypt1;
                end

				//FINISHED TASK 2, BEGIN DECRYPTION
            decrypt1:
                begin
                    encrypted_address <= k - 1;					//get k address
                    state <= decrypt_delay;
                end

            decrypt_delay:
                begin
                    state <= decrypt2;          				// wait one cycle to read E[k]
                end

            decrypt2:
                begin
                    encrypt_k = encrypted_q;    				// get value of E[k]
                    state <= decrypt3;
                end

            decrypt3:
                begin
                    decrypted_address <= k - 1;						// set D[k] address
                    decrypted_data <= Sf_value ^ encrypt_k;		//compute decrypted_data
                    decrypted_wren <= 1'b1;
                    state <= read_decryption;
                end

            read_decryption:
                begin
                    decrypted_address <= k - 1;					//read decrypted address, start at k-1 because k = 1 at the start
                    decrypted_wren <= 1'b0;
                    state <= read_decrypt_delay;
                end

            read_decrypt_delay:
                begin
                    state <= check_decrypt;						//wait a cycle to check the decryption
                end	

            check_decrypt:
                begin
                    if ( (decrypted_q == 8'h20) || ((decrypted_q >= 8'h61) && (decrypted_q <= 8'h7A)) ) begin
                        //all 32 characters of the decoded output must be lowercase letters or a space
								k = k + 1; //if true, then increment k by 1u
                        if ( k > 32 ) state <= decryption_successful;	//if k has reached end of message, then decryption is successful
                        else state <= set_read_SI1;							//if k has not reached end of message, then continue reading next index
                    end

                    else
                    begin
                        //if value is not lowercase letter, then reset and try the next key
                        {i,j,k,f,Si_value,Sj_value} <= {32'b0,32'b0,32'b0,32'b0,32'b0,32'b0};
                        state <= increment_key;
                    end
                end

				//DECRYPTION SUCCESSFUL BOI
            decryption_successful:
                begin
                    decrypt_success <= 1'b1;
                    state <= decryption_successful;
                end
			
				//DECRYPTION NOT SUCCESSFUL
            decryption_failed:
                begin
                    decrypt_failed <= 1'b1;
                    state <= decryption_failed;
                end
        endcase

    end //end of else
end //end of main

//LED logic, prints the highest 8 bits to LED
//also sets LED[0] and LED[1] flags depending on if decryption was successful or not
always_comb
    begin
        LEDR[9:2] = secret_key_24_bit[23:16];
        if (decrypt_success == 1'b1) 
		  begin
            LEDR = 1;
        end 
		  else 
		  begin
            LEDR = 0;
        end

        if (decrypt_failed == 1'b1) begin
            LEDR[1] = 1;
        end 
			 else
			 begin
            LEDR[1] = 0;
        end
    end
endmodule
