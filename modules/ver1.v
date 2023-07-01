// this is the verification module.
// this ensures that each voter having an unique id can vote 
// only once and thereby checks the stored register whether
// a voter has voted previously or not from checking his/her 
// unique ID
// There is huge scope of modification in this module. Please 
// try to improve while you work on it.

module ver1(serial, checker, auth, red_led, green_led, valid_vote, reset);
    input [4:0] serial;
    input checker, auth, valid_vote, reset; //number of voters
    reg [31:0] prevdata=0; //each voter gets corresponding register
    output reg red_led, green_led;
    always@(posedge checker, posedge auth, posedge valid_vote, posedge reset) begin
		if(reset) begin
			prevdata <= 0;
			red_led = 1'b1;
			green_led = 1'b1;
		end
		
		if(checker) begin
			if(prevdata[serial]==1'b0)begin
				red_led = 1'b0;
				prevdata[serial]=1'b1;
			end
			/*else begin
				red_led = 1'b1;
			end*/
		end
		
		
		if(auth) begin
			if(!red_led) begin
				red_led = 1'b1;
				green_led = 1'b0;
			end
			/*else begin
				red_led = 1'b0;
				green_led = 1'b1;
			end	*/
		end
		
		
		if(valid_vote) begin
			if(!green_led) green_led = 1'b1;
			//else green_led = 1'b0;
		end 
    end
    
endmodule    
