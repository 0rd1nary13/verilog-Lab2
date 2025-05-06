module alarm(
  input[6:0]   tmin,
               amin,
			   thrs,
			   ahrs,
         tday,
         aday,						 
  output logic buzz
);

    /* fill in the guts:
	buzz = 1 when tmin and thrs match amin and ahrs, respectively */

  always_comb begin
    buzz = (tmin == amin) && (thrs == ahrs);
    case (aday) 
      0,1,2,3,4,5: buzz = buzz && (tday == aday || tday == aday + 1); 
      6 : buzz = buzz && (tday == aday || tday == 0);
      7 : buzz = buzz;
      endcase
  end

endmodule