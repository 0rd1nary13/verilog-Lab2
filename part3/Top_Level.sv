// CSE140L  		 part 3
// see Structural Diagram in Lab2 assignment writeup
// fill in missing connections and parameters
module Top_Level #(parameter NS=60, NH=24, ND=7, NM=12)(
  input Reset,
        Timeset, 	  // manual buttons
        Alarmset,	  //	(five total)
		Minadv,
		Hrsadv,
		Dayadv,
		Datadv,
		Monadv,
		Alarmon,
		Pulse,		  // digital clock, assume 1 cycle/sec.
// 6 decimal digit display (7 segment)
  output [6:0] S1disp, S0disp, 	     // 2-digit seconds display
               M1disp, M0disp, 
               H1disp, H0disp,
               D0disp,              // Day of week display for part 2
               N1disp, N0disp,      // Month display 1 to 12
			   T1disp, T0disp,      // Date advance
  output logic Buzz);	           // alarm sounds

// ---------internal connections Starts --------
  logic[6:0] TSec, TMin, THrs, TDay,     // clock/time 
             AMin, AHrs, ADay;		   // alarm setting
  logic[6:0] Min, Hrs, Day;
  logic S_max, M_max, H_max, D_max, 	   // "carry out" from sec -> min, min -> hrs, hrs -> date -> Month
        TMen, THen, TDen, AMen, AHen, ADen,
        TTen, TNen ; // (N) Date Enable & (T) Month enable
  logic alarm_trigger;             // alarm internal trigger signal

// Date and Month Variables
  logic [5:0] TDate;       // current calendar date (1–31)
  logic [3:0] TMonth;      // current month (1–12)
  logic D_rollover;        // goes high when date hits max and resets
  
  function automatic [5:0] max_days_in_month(input [3:0] m);
    case (m)
      1, 3, 5, 7, 8, 10, 12: max_days_in_month = 31;
      4, 6, 9, 11:           max_days_in_month = 30;
      2:                    max_days_in_month = 29; // assuming leap year
      default:              max_days_in_month = 31;
    endcase

// set control logic - revised based on component specifications
// T: time, A: Alarm, en:enable, eg: TMen: Time Minute Enable
  assign TMen = (Timeset & Minadv) | (!Timeset & S_max);  // Minute counter enable
  assign THen = (Timeset & Hrsadv) | (!Timeset & S_max & M_max);  // Hour counter enable - increment when both sec & min are max
  assign TDen = (Timeset & Dayadv) | (!Timeset & S_max & M_max & H_max); // Day counter en
  assign TNen = (Timeset & Datadv) | (!Timeset & S_max & M_max & H_max); // Date counter en
  assign TTen = (Timeset & Monadv) | (!Timeset & D_max & S_max & M_max & H_max); //Month counter en
  
  assign AMen = Alarmset & Minadv;           // Alarm minute setting enable
  assign AHen = Alarmset & Hrsadv;           // Alarm hour setting enable
  assign ADen = Alarmset & Dayadv;           // Alarm day setting enable
// Time or alarm display selection
  assign Min = Alarmset? AMin : TMin;        // Display minutes (time or alarm)
  assign Hrs = Alarmset? AHrs : THrs;        // Display hours (time or alarm)
  assign Day = Alarmset? ADay : TDay;        // Display Days (time or alarm)
// ---------internal connections Ends --------


// ------------------ Time Counters Start ------------------
// (almost) free-running seconds counter	-- be sure to set modulus inputs on ct_mod_N modules
  ct_mod_N  Sct(
  // input ports
    .clk(Pulse), .rst(Reset), .en(!Timeset), .modulus(7'(NS)),
  // output ports    
    .ct_out(TSec), .ct_max(S_max));

// minutes counter -- runs at either 1/sec while being set or 1/60sec normally
  ct_mod_N Mct(
  // input ports     
    .clk(Pulse), .rst(Reset), .en(TMen), .modulus(7'(NS)),
  // output ports
    .ct_out(TMin), .ct_max(M_max));

// hours counter -- runs at either 1/sec or 1/60min
  ct_mod_N  Hct(
  // input ports
	.clk(Pulse), .rst(Reset), .en(THen), .modulus(7'(NH)),
  // output ports
    .ct_out(THrs), .ct_max(H_max));


// days counter -- runs at either 1/sec or 1/24hr
  ct_mod_N Dct(
    //input ports
    .clk(Pulse), .rst(Reset), .en(TDen), .modulus(7'(ND)),
    //output ports
    .ct_out(TDay), .ct_max(D_max) //we might want a carry out, 7days -> week
  	);

 // Date and Month tracking
  always_ff @(posedge Pulse or posedge Reset) begin
    if (Reset) begin
      TDate <= 1;
      TMonth <= 1;
    end else if (TDen) begin // TDen already handles button OR real time
      if (TDate == max_days_in_month(TMonth)) begin
        TDate <= 1;
        if (TMonth == 12)
          TMonth <= 1;
        else
          TMonth <= TMonth + 1;
      end else begin
        TDate <= TDate + 1;
      end
    end
  end

//------------------ Time Counters End ------------------

// ------------------ Alarm Registers Start ------------------
// alarm set registers -- either hold or advance 1/sec while being set
  ct_mod_N Mreg(
// input ports
    .clk(Pulse), .rst(Reset), .en(AMen), .modulus(7'(NS)),
// output ports    
    .ct_out(AMin), .ct_max()  ); 

  ct_mod_N  Hreg(
// input ports
    .clk(Pulse), .rst(Reset), .en(AHen), .modulus(7'(NH)),
// output ports    
    .ct_out(AHrs), .ct_max() ); 

  ct_mod_N Dreg(
    //input ports
    .clk(Pulse), .rst(Reset), .en(ADen), .modulus(7'(ND)),
    //output ports
    .ct_out(ADay), .ct_max() );

// ------------------ Alarm Registers End ------------------

// ------------------ Displays Start ------------------
// display drivers (2 digits each, 6 digits total)
  // seconds display
  lcd_int Sdisp(					  
    .bin_in    (TSec)  ,
	.Segment1  (S1disp),
	.Segment0  (S0disp)
	);

  // Minutes display
  lcd_int Mdisp(           
    .bin_in    (Min),
	.Segment1  (M1disp),
	.Segment0  (M0disp)
	);

  // Hours display
  lcd_int Hdisp(
    .bin_in    (Hrs),
	.Segment1  (H1disp),
	.Segment0  (H0disp)
	);
  
  // Days display (Days of the Week)
  lcd_int Ddisp(
    .bin_in  (Day),
	.Segment1  (),
	.Segment0  (D0disp)  
  	);
  
  // Month display
  lcd_int Ndisp(
    .bin_in  (TMonth),
	.Segment1  (N1disp),
	.Segment0  (N0disp)  
  	);

  // Date display
  lcd_int Tdisp(
    .bin_in  (TDate),
	.Segment1  (T1disp),
	.Segment0  (T0disp)  
  	);

// buzz off :)	  make the connections
  alarm a1(
    .tmin(TMin), .amin(AMin),
    .thrs(THrs), .ahrs(AHrs), 
    .tday(TDay), .aday(ADay),
    .buzz(alarm_trigger)
	);
	
// Enable/disable alarm based on Alarmon setting
  assign Buzz = alarm_trigger & Alarmon;

endmodule