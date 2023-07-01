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
