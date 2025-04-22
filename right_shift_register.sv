// Right shift register with an arithmetic or logical shift mode
module right_shift_register #(parameter WIDTH = 16)(
    input                    clk,
    input                    enable,
    input        [WIDTH-1:0] in, // input to shift
    input                    mode, // arithmetic (0) or logical (1) shift
    output logic [WIDTH-1:0] out); // shifted input

//    enable   mode      out  
//    0       0         hold (no change in output)
//		0       1	        hold
//		1       1	        load and logical right shift
//		1		    0         load and arithmetic right shift
	
  always_ff @(posedge clk)begin
    if(enable)
      if(mode) 
          out <= {1'b0, in[WIDTH-1:1]} ;
        else 
          out <= {in[WIDTH-1], in[WIDTH-1:1]};
  end



endmodule
