module right_shift_register_tb;

  //Variables Setup
  parameter WIDTH = 8;
  logic clk, 
        enable, // shift (enable = 1) or hold (enable = 0)
        mode; // arithmetic (0) or logical (1) shift
  logic [WIDTH-1:0] in; // input to shift
  reg [WIDTH-1:0] out; // shifted input

  // module instances
  right_shift_register #(.WIDTH(WIDTH)) rsreg(
    .clk(clk),
    .enable(enable),
    .in(in),
    .mode(mode),
    .out(out)
  );

  initial begin
    $dumpfile("dump.vcd"); $dumpvars;

    //TODO: implement the testbenchc
    // Expect out = 1000 1111
    #1 in = 8'b10001111;
    enable = 0;
    #1 clk = 0;
    #1 clk = 1;

    // Expect out = 1100 0111
    enable = 1;
    #1 mode = 0;
    #1 clk = 0;
    #1 clk = 1;

    // Expect out = 0110 0011
    #1 mode = 1;
    #1 clk = 0;
    #1 clk = 1;

  end
endmodule