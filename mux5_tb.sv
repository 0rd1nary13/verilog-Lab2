module mux5_tb;

  parameter width = 8;
  logic [width-1: 0]d0=0,d1=1,d2=2,d3=3,d4=4, y;
  logic [1:0]s;
  
  
  mux5 #(.WIDTH(width))m5(
    .d0(d0),
    .d1(d1),
    .d2(d2),
    .d3(d3),
    .d4(d4),
    .s(s),
    .y(y));
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    for(integer i = 0; i < 8; i++)
      #10ns s = i;

    #10ns d4 = 15;
    #10ns d1 = 100;
    #10ns s = 1;

    #100ns $stop;
  end
endmodule