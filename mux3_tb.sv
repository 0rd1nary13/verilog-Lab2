module mux3_tb;

  parameter width = 8;
  logic [width-1: 0]d0 = 0, d1 = 1,d2 = 2, y;
  logic [1:0]s;
  
  
  mux3 #(.WIDTH(width))m3(
    .d0(d0),
    .d1(d1),
    .d2(d2),
    .s(s),
    .y(y));
  
  initial begin
    //All possible selection
    for(integer i = 0; i < 4; i++)
      #10ns s = i;
    
    //Assign different value from d0 to d2 
    for(integer i = 0; i < 8; i++) begin
      #10ns d0 = i;
      #10ns d1 = i*2;
      #10ns d2 = i*4;
      for(integer j = 0; j < 4; j++)
      	#10ns s = j;
    end
    
    #10ns s = 0;
    #100ns $stop;
  end
endmodule