// 3:1 MULTIPLEXER	(combinational 3-way switch)
module  mux3 #(parameter WIDTH = 8)
  (input  [WIDTH-1:0] d0, d1, d2,
			input [1:0]  s, 
             output logic[WIDTH-1:0] y);

    always_comb 
        y = (d0 & { WIDTH{!s[0] && !s[1]}}) |
         (d1 & { WIDTH{s[0] && !s[1]}}) |
         {d2 & { WIDTH{!s[0] && s[1]}}};
endmodule
