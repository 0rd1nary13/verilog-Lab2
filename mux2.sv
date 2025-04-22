// 2:1 mux (selector) of N-wide buses
// CSE140L
module mux2 #(parameter WIDTH = 8)
 (input        [WIDTH-1:0] d0, d1, 
  input                    s, 
  output logic [WIDTH-1:0] y);

// s   y
// 0   d0	y[7:0] = d0[7:0]
// 1   d1	y[7:0] = d1[7:0]
  always_comb begin
  if(s == 0)
    y[WIDTH - 1: 0] = d0[WIDTH - 1: 0];
  else
    y[WIDTH - 1: 0] = d1[WIDTH - 1: 0];
  end

endmodule


