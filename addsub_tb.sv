module addsub_tb;
  
  parameter dw = 8;
  logic [dw-1:0] a = 0, b = 0;
  logic add_sub = 1;	 // if this is 1, add; else subtract
  logic[dw-1:0] y;

  addsub #(.dw(dw)) _adsb(
    .dataa(a),
    .datab(b),
    .add_sub(add_sub),
    .result(y)
  );

  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    // At the start, y = 128 + 127 = 255/-1
    #1 a = 128;
    #1 b = 127;   
    
     // y = 1
    #1 add_sub = 0;   
    
    #1 // a = 127, b = 128
    a <= b;
    b <= a;
    // y = 128-127 = -1/255
    #1  $stop;
  end
endmodule