// 5:1 MULTIPLEXER	(combinational 5-way switch)
module mux5 (input        d0, d1, d2, d3, d4,
             input [2:0]  s, 
             output logic y);

    always_comb 
        case(s) 
        0: y = d0;
        1: y = d1;
        2: y = d2;
        3: y = d3;
        4: y = d4;
        5: y = 0;
        6: y = 0;
        7: y = 0;
        endcase
endmodule
