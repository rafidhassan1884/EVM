// Code your design here
module evm(  // voting Machine module
input clock,
input reset,
input mode,
input checker,
input [4:0] serial,
input button1,
input button2,
input button3,
input button4, 
output green_led, red_led, 
output [7:0] seg1, seg2
);

wire valid_vote_1;
wire valid_vote_2;
wire valid_vote_3;
wire auth_vote_4;
//wire auth_vote_verified; //
wire [7:0] cand1_vote_recvd;
wire [7:0] cand2_vote_recvd;
wire [7:0] cand3_vote_recvd;
wire [7:0] auth_vote_recvd;
wire anyValidVote;
wire [7:0]led;

assign anyValidVote = valid_vote_1|valid_vote_2|valid_vote_3|auth_vote_4;
assign anyTrueVote = true_1| true_2| true_3;

buttonControl ck(
.clock(clock),
.reset(reset),
.button(checker),
.valid_vote(checker_b)
);

ver1 verifer(
.serial(serial),
.checker(checker_b),
.auth(auth_vote_4),
.red_led(red_led),
.green_led(green_led),
.valid_vote(anyTrueVote),
.reset(reset)
);

buttonControl bc1(
.clock(clock),
.reset(reset),
.button(button1),
.valid_vote(valid_vote_1)
);
buttonControl bc2(
.clock(clock),
.reset(reset),
.button(button2),
.valid_vote(valid_vote_2)
);
buttonControl bc3(
.clock(clock),
.reset(reset),
.button(button3),
.valid_vote(valid_vote_3)
);
/*buttonControl bc4(
.clock(clock),
.reset(reset),
.button(button4),
.valid_vote(auth_vote_4)
);*/

authControl bc4(
.clock(clock),
.reset(reset),
.button(button4),
.red_led(red_led),
.valid_vote(auth_vote_4)
);
//df df10(.d(!red_led), .clk(auth_vote_4), .reset(reset), .q(auth_vote_verified)); // modified
wire true_1, true_2, true_3;
block b1(
.auth(auth_vote_4),
.vote1(valid_vote_1),
.vote2(valid_vote_2),
.vote3(valid_vote_3),
.clk(clock),
.reset(reset),
.vv1(true_1),
.vv2(true_2),
.vv3(true_3));

 voteLogger VL(
.clock(clock),
.reset(reset),
.mode(mode),
.cand1_vote_valid(true_1),
.cand2_vote_valid(true_2),
.cand3_vote_valid(true_3),
.cand4_vote_valid(auth_vote_4),
.cand1_vote_recvd(cand1_vote_recvd),
.cand2_vote_recvd(cand2_vote_recvd),
.cand3_vote_recvd(cand3_vote_recvd),
.cand4_vote_recvd(auth_vote_recvd)
);

modeControl MC(
.clock(clock),
.reset(reset),
.mode(mode),
.valid_vote_casted(anyValidVote),
.candidate1_vote(cand1_vote_recvd),
.candidate2_vote(cand2_vote_recvd),
.candidate3_vote(cand3_vote_recvd),
.candidate4_vote(auth_vote_recvd),
.candidate1_button_press(valid_vote_1),
.candidate2_button_press(valid_vote_2),
.candidate3_button_press(valid_vote_3),
.candidate4_button_press(auth_vote_4),
.leds(led)
);

wire [11:0] bcd;
bin2bcd b2b(
	.bin(led),
	.bcd(bcd));
segment7 sv1(
	.bcd(bcd[3:0]),
	.seg(seg2));
segment7 sv2(
	.bcd(bcd[7:4]),
	.seg(seg1));
endmodule

module buttonControl(
input clock,
input reset, 
input button,
output reg valid_vote
);

reg[30:0] counter;

always @(posedge clock)
begin
  if(reset)
  	counter <= 0;
  else
  begin
    if(~button & counter < 50001)
    	counter <= counter + 1;
    else if(button)
    	counter <= 0;
  end
end

always @(posedge clock)
begin
if(reset)
valid_vote <= 1'b0;
else
begin
if(counter == 50000)
valid_vote <= 1'b1;
else
valid_vote <= 1'b0;
end
end

endmodule




module authControl(
input clock,
input reset, 
input button,
input red_led,
output reg valid_vote
);

reg[30:0] counter;

always @(posedge clock)
begin
  if(reset)
  	counter <= 0;
  else
  begin
    if(~button & counter < 50001)
    	counter <= counter + 1;
    else if(button)
    	counter <= 0;
  end
end

always @(posedge clock)
begin
if(reset)
valid_vote <= 1'b0;
else
begin
if(counter == 50000 && !red_led)
valid_vote <= 1'b1;
else
valid_vote <= 1'b0;
end
end

endmodule







module modeControl(  // mode control module
input clock, 
input reset,
input mode,
input valid_vote_casted,
input [7:0] candidate1_vote,
input [7:0] candidate2_vote,
input [7:0] candidate3_vote,
input [7:0] candidate4_vote,
input candidate1_button_press,
input candidate2_button_press,
input candidate3_button_press,
input candidate4_button_press,
output reg [7:0] leds
);

reg [30:0] counter;

always @(posedge clock)
begin
if(reset)
counter <= 0; // whenever reset is pressed,counter started from 0
else if(valid_vote_casted) // if a valid vote is casted, counter becomes 1
counter <= counter+1;
  else if(counter != 0 & counter < 10) // if counter is not 0, increment it till 10
counter <= counter+1;
else // once counter becomes 10, reset it to zero
counter <= 0;
end

always @(posedge clock)
begin
if(reset)
leds <= 0;
else
begin
if(mode == 0 & counter > 0) // mode0 -> voting mode, mode 1 -> result mode
leds <= 8'hFF;
else if(mode == 0)
leds <= 8'h00;
else if(mode == 1) // result mode
begin
if(candidate1_button_press)
leds <= candidate1_vote;
else if(candidate2_button_press)
leds <= candidate2_vote;
else if(candidate3_button_press)
leds <= candidate3_vote;
else if(candidate4_button_press)
leds <= candidate4_vote;
end
end

end
endmodule



module voteLogger(  // voteLogger module
input clock, 
input reset, 
input mode,
input cand1_vote_valid,
input cand2_vote_valid,
input cand3_vote_valid,
input cand4_vote_valid,
output reg [7:0] cand1_vote_recvd,
output reg [7:0] cand2_vote_recvd,
output reg [7:0] cand3_vote_recvd,
output reg [7:0] cand4_vote_recvd
);

always @(posedge clock)
begin
if(reset)
begin
cand1_vote_recvd <= 0;
cand2_vote_recvd <= 0;
cand3_vote_recvd <= 0;
cand4_vote_recvd <= 0;
end
else
begin
if(cand1_vote_valid & mode == 0)
cand1_vote_recvd <= cand1_vote_recvd+1;
else if(cand2_vote_valid & mode == 0)
cand2_vote_recvd <= cand2_vote_recvd+1;
else if(cand3_vote_valid & mode == 0)
cand3_vote_recvd <= cand3_vote_recvd+1;
else if(cand4_vote_valid & mode == 0)
cand4_vote_recvd <= cand4_vote_recvd+1;
end
end
endmodule


// binary to decimal
module bin2bcd(
    bin,
     bcd
    );

    //input ports and their sizes
    input [7:0] bin;
    //output ports and, their size
    output [11:0] bcd;
    //Internal variables
    reg [11 : 0] bcd; 
    reg [3:0] i;   
     
     //Always block - implement the Double Dabble algorithm
     always @(bin)
        begin
            bcd = 0; //initialize bcd to zero.
            for (i = 0; i < 8; i = i+1) //run for 8 iterations
            begin
                bcd = {bcd[10:0],bin[7-i]}; //concatenation
                    
                //if a hex digit of 'bcd' is more than 4, add 3 to it.  
                if(i < 7 && bcd[3:0] > 4) 
                    bcd[3:0] = bcd[3:0] + 3;
                if(i < 7 && bcd[7:4] > 4)
                    bcd[7:4] = bcd[7:4] + 3;
                if(i < 7 && bcd[11:8] > 4)
                    bcd[11:8] = bcd[11:8] + 3;  
            end
        end     
                
endmodule

module segment7(
     bcd,
     seg
    );
     
     //Declare inputs,outputs and internal variables.
     input [3:0] bcd;
     output [7:0] seg;
     reg [7:0] seg;

//always block for converting bcd digit into 7 segment format
    always @(bcd)
    begin
        case (bcd) //case statement
            0 : seg = 8'b00000011;
            1 : seg = 8'b10011111;
            2 : seg = 8'b00100101;
            3 : seg = 8'b00001101;
            4 : seg = 8'b10011001;
            5 : seg = 8'b01001001;
            6 : seg = 8'b01000001;
            7 : seg = 8'b00011111;
            8 : seg = 8'b00000001;
            9 : seg = 8'b00001001;
            //switch off 7 segment character when the bcd digit is not a decimal number.
            default : seg = 8'b11111111; 
        endcase
    end
    
endmodule

// Code your design here
module block(input auth, vote1, vote2, vote3, clk, reset,
             output vv1, vv2, vv3);
  wire q1, q2, a;
  df d1(.d(1'b1),
         .clk(vote1),
         .reset(vv1|reset|auth),
         .q(q1));
  
  df d2(.d(1'b1),
         .clk(vote2),
         .reset(vv2|reset|auth),
         .q(q2));
  
  df d3(.d(1'b1),
         .clk(vote3),
         .reset(vv3|reset|auth),
         .q(q3));
         
  df d4(.d(1'b1),
         .clk(auth),
         .reset(vv1|vv2|vv3|reset),
         .q(a));
  
  // 2nd stage
  df d5(.d(q1 & a),
         .clk(clk),
         .reset(1'b0),
         .q(vv1));
  
  df d6(.d(q2 & a),
         .clk(clk),
         .reset(1'b0),
         .q(vv2));
         
  df d7(.d(q3 & a),
         .clk(clk),
         .reset(1'b0),
         .q(vv3));

endmodule

module df(input d, clk, reset,
           output reg q);
  always @(posedge clk or posedge reset) begin
    if(reset) q = 0;
    else q = d;
  end
endmodule

// verification module
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
    
       
    
    