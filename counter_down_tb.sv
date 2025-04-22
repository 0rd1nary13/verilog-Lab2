module counter_down_tb;
  parameter dw= 3, WIDTH = 7;
  logic clk = 0, reset = 1, ena = 1;
  logic [dw-1:0] result;

  counter_down #(.dw(dw), .WIDTH(WIDTH)) cd(
    .clk (clk),
    .reset (reset),
    .ena    (ena),
    .result (result)
  );

initial begin
  $dumpfile("dump.vcd"); $dumpvars;
  
  // reset value in result
  #1 clk = 1;
  // turn off reset
  #1 reset = 0; // if no delay 

  // count down
  for(integer i = 0; i < 10; i++) begin
    #1  clk = 0;
    #1  clk = 1;
  end
end

endmodule