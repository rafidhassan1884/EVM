// this is my designed block. It can be replaced with a very 
// easy FSM. However, this block takes all verified vote and 
// also the permission from authority. The authority button is
// reset after a valid vote is casted so that only one vote can
// be casted after authority button is pressed once. for each vote
// a push from authority button is required and thereby more than
// one vote cannot be casted at one go.

// df here means a simple d-flip flop
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
