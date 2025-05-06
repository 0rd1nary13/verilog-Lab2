// CSE140 lab 2  
// How does this work? How long does the alarm stay on? 
// (buzz is the alarm itself)
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
    // Buzz specifically at 08:10 (morning) on days 0-4
    if (thrs == 8 && tmin == 10 && tday <= 4)
      buzz = 1;
    else
      buzz = 0;
  end

endmodule