// CSE140L part 3
// Updated Top_Level module with fixed Datadv+Monadv logic and leap year support
module Top_Level #(parameter NS=60, NH=24, ND=7, NM=12)(
  input Reset,
        Timeset,
        Alarmset,
        Minadv,
        Hrsadv,
        Dayadv,
        Datadv,
        Monadv,
        Alarmon,
        Pulse,
  output [6:0] S1disp, S0disp,
               M1disp, M0disp,
               H1disp, H0disp,
               D0disp,
               N1disp, N0disp,
               T1disp, T0disp,
  output logic Buzz);

  localparam logic [15:0] YEAR = 2024;

  logic[6:0] TSec, TMin, THrs, TDay;
  logic[6:0] AMin, AHrs, ADay;
  logic[6:0] Min, Hrs, Day;
  logic S_max, M_max, H_max, D_max;
  logic TMen, THen, TDen, AMen, AHen, ADen;
  logic TTen, TNen;
  logic alarm_trigger;

  logic [5:0] TDate;
  logic [3:0] TMonth;
  logic D_rollover;
  logic date_rollover;
  logic [5:0] max_days;

  function automatic [5:0] max_days_in_month(input [3:0] m, input [15:0] year);
    unique case (m)
      1, 3, 5, 7, 8, 10, 12: max_days_in_month = 31;
      4, 6, 9, 11         : max_days_in_month = 30;
      2 : begin
        if ((year % 400 == 0) || (year % 4 == 0 && year % 100 != 0))
          max_days_in_month = 29;
        else
          max_days_in_month = 28;
      end
      default: max_days_in_month = 31;
    endcase
  endfunction

  always_comb begin
    max_days = max_days_in_month(TMonth, YEAR);
    date_rollover = (TDate >= max_days);
  end

  assign TMen = (Timeset & Minadv) | (!Timeset & S_max);
  assign THen = (Timeset & Hrsadv) | (!Timeset & S_max & M_max);
  assign TDen = (Timeset & Dayadv) | (!Timeset & S_max & M_max & H_max);
  assign TNen = (Timeset & Datadv) | (!Timeset & S_max & M_max & H_max);
  assign D_rollover = (TDate >= max_days_in_month(TMonth, YEAR)) & S_max & M_max & H_max;
  assign TTen = (Timeset & Monadv) | (!Timeset & D_rollover);
  assign AMen = Alarmset & Minadv;
  assign AHen = Alarmset & Hrsadv;
  assign ADen = Alarmset & Dayadv;

  assign Min = Alarmset ? AMin : TMin;
  assign Hrs = Alarmset ? AHrs : THrs;
  assign Day = Alarmset ? ADay : TDay;

  ct_mod_N Sct(.clk(Pulse), .rst(Reset), .en(!Timeset), .modulus(7'(NS)), .ct_out(TSec), .ct_max(S_max));
  ct_mod_N Mct(.clk(Pulse), .rst(Reset), .en(TMen), .modulus(7'(NS)), .ct_out(TMin), .ct_max(M_max));
  ct_mod_N Hct(.clk(Pulse), .rst(Reset), .en(THen), .modulus(7'(NH)), .ct_out(THrs), .ct_max(H_max));
  ct_mod_N Dct(.clk(Pulse), .rst(Reset), .en(TDen), .modulus(7'(ND)), .ct_out(TDay), .ct_max(D_max));

  always_ff @(posedge Pulse or posedge Reset) begin
    if (Reset) begin
      TDate <= 1;
      TMonth <= 1;
    end else begin
      if (Timeset) begin
        if (Monadv) begin
          if (TMonth == 12)
            TMonth <= 1;
          else
            TMonth <= TMonth + 1;
        end
        if (Datadv) begin
          if (TDate >= max_days_in_month(TMonth, YEAR))
            TDate <= 1;
          else
            TDate <= TDate + 1;
        end
      end else if (S_max & M_max & H_max) begin
        if (TDate >= max_days_in_month(TMonth, YEAR)) begin
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
  end

  ct_mod_N Mreg(.clk(Pulse), .rst(Reset), .en(AMen), .modulus(7'(NS)), .ct_out(AMin), .ct_max());
  ct_mod_N Hreg(.clk(Pulse), .rst(Reset), .en(AHen), .modulus(7'(NH)), .ct_out(AHrs), .ct_max());
  ct_mod_N Dreg(.clk(Pulse), .rst(Reset), .en(ADen), .modulus(7'(ND)), .ct_out(ADay), .ct_max());

  lcd_int Sdisp(.bin_in(TSec), .Segment1(S1disp), .Segment0(S0disp));
  lcd_int Mdisp(.bin_in(Min), .Segment1(M1disp), .Segment0(M0disp));
  lcd_int Hdisp(.bin_in(Hrs), .Segment1(H1disp), .Segment0(H0disp));
  lcd_int Ddisp(.bin_in(Day), .Segment1(), .Segment0(D0disp));
  lcd_int Ndisp(.bin_in({3'b0, TMonth}), .Segment1(N1disp), .Segment0(N0disp));
  lcd_int Tdisp(.bin_in({1'b0, TDate}), .Segment1(T1disp), .Segment0(T0disp));

  alarm a1(
    .tmin(TMin), .amin(AMin),
    .thrs(THrs), .ahrs(AHrs),
    .tday(TDay), .aday(ADay),
    .buzz(alarm_trigger)
  );

  assign Buzz = alarm_trigger & Alarmon;
endmodule
