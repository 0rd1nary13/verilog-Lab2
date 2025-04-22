// micro-program counter, asynchronous reset
// Active high load
// Active low increment
module upcreg(
  input              clk,
  input              reset,
  input              load_incr,
  input [4:0]        upc_next,
  output logic [4:0] upc);

//   reset    load_incr     upc
//     1		      1         0
//	   1		      0         0
//	   0		      1         upc_next
//	   0	        0         upc+1
  always_ff @ (posedge clk, posedge reset) begin
    if(reset)upc <= 0;
    else if(load_incr) upc <= upc_next;
    else upc <= upc + 1;
  end
  
endmodule    