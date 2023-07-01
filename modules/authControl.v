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
