module mux2_tb;

  parameter width = 8; //number of bit of the input/output
  logic [width-1: 0]d0 = 0, d1 = 1, y;
  logic s;
  
  
  mux2 #(.WIDTH(width))m2(
    .d0(d0),
    .d1(d1),
    .s(s),
    .y(y)
    );
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    //Test all selection 0: y=d0, 1: y= d1
    for(integer i = 0; i < 2; i++)
      #10ns s = i;
    // currently s= 1
    #10ns d1 = 10; // y= 10
    #10ns d0 = 14; 
    #10ns s = 0; // y= 14
    #100ns $stop;
  end

endmodule