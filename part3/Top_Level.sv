
module Top_Level
#(  parameter int NS = 60,          // seconds / minutes modulus
    parameter int NH = 24,          // hours
    parameter int ND = 7,           // day-of-week
    parameter int NM = 12 )         // months
(
    input  logic        Reset,
                      Timeset,      // manual buttons
                      Alarmset,     // (five total)
                      Minadv,
                      Hrsadv,
                      Dayadv,
                      Datadv,
                      Monadv,
                      Alarmon,
                      Pulse,        // 1 Hz clock
    // 7-segment displays
    output logic [6:0] S1disp, S0disp,
                       M1disp, M0disp,
                       H1disp, H0disp,
                       D0disp,
                       N1disp, N0disp,
                       T1disp, T0disp,
    output logic       Buzz          // alarm output
);

    //------------------------------------------------------------------
    // ‖  local constants / small helpers
    //------------------------------------------------------------------
    localparam int YEAR = 2024;

    // cast integer parameters to 7-bit wires once so we never repeat the
    // sized-constant dance
    localparam logic [6:0] NS7 = NS;
    localparam logic [6:0] NH7 = NH;
    localparam logic [6:0] ND7 = ND;

    // -----------------------------------------------------------------
    // ‖  nets
    // -----------------------------------------------------------------
    logic [6:0] TSec, TMin, THrs, TDay;     // time
    logic [6:0] AMin, AHrs, ADay;           // alarm registers
    logic [6:0] Min,  Hrs,  Day;            // current values to display

    logic       S_max, M_max, H_max;        // “carry” flags
    logic       TMen, THen, TDen;           // time-counter enables
    logic       AMen, AHen, ADen;           // alarm-reg enables

    // calendar
    logic [5:0] TDate;                      // 1--31
    logic [3:0] TMonth;                     // 1--12
    logic [5:0] max_days;
    logic       date_rollover;              // TDate hit month max

    // alarm
    logic       alarm_trigger;

    always_comb begin
        unique case (TMonth)
            4'd1,4'd3,4'd5,4'd7,4'd8,4'd10,4'd12:  max_days = 31;
            4'd4,4'd6,4'd9,4'd11:                  max_days = 30;
            default:                               // February
                max_days = ( (YEAR%400==0) || (YEAR%4==0 && YEAR%100!=0) )
                           ? 29 : 28;
        endcase
        date_rollover = (TDate == max_days);   // true the *day* it will wrap
    end


    assign TMen = (Timeset & Minadv) |
                  (!Timeset & S_max);

    assign THen = (Timeset & Hrsadv) |
                  (!Timeset & S_max & M_max);

    assign TDen = (Timeset & Dayadv) |
                  (!Timeset & S_max & M_max & H_max);

    // Manual alarm-setting
    assign AMen = Alarmset & Minadv;
    assign AHen = Alarmset & Hrsadv;
    assign ADen = Alarmset & Dayadv;

    // Which values go to the 7-segments
    assign Min = Alarmset ? AMin : TMin;
    assign Hrs = Alarmset ? AHrs : THrs;
    assign Day = Alarmset ? ADay : TDay;


    ct_mod_N Sct (.clk(Pulse), .rst(Reset), .en(!Timeset),
                  .modulus(NS7), .ct_out(TSec), .ct_max(S_max));

    ct_mod_N Mct (.clk(Pulse), .rst(Reset), .en(TMen),
                  .modulus(NS7), .ct_out(TMin), .ct_max(M_max));

    ct_mod_N Hct (.clk(Pulse), .rst(Reset), .en(THen),
                  .modulus(NH7), .ct_out(THrs), .ct_max(H_max));

    ct_mod_N Dct (.clk(Pulse), .rst(Reset), .en(TDen),
                  .modulus(ND7), .ct_out(TDay), .ct_max(/*unused*/));


    always_ff @(posedge Pulse or posedge Reset) begin
        if (Reset) begin
            TDate  <= 6'd1;
            TMonth <= 4'd1;
        end
        else if (Timeset && Datadv) begin                   // manual date
            if (TDate == max_days) TDate <= 1;
            else                   TDate <= TDate + 1;
        end
        else if (Timeset && Monadv) begin                   // manual month
            if (TMonth == 12) TMonth <= 1;
            else              TMonth <= TMonth + 1;
        end
        else if (!Timeset && S_max && M_max && H_max) begin // midnight
            if (date_rollover) begin                        // month rolls
                TDate <= 1;
                TMonth <= (TMonth==12) ? 1 : TMonth + 1;
            end
            else begin                                      // normal day
                TDate <= TDate + 1;
            end
        end
    end
  
    ct_mod_N Mreg (.clk(Pulse), .rst(Reset), .en(AMen),
                   .modulus(NS7), .ct_out(AMin));

    ct_mod_N Hreg (.clk(Pulse), .rst(Reset), .en(AHen),
                   .modulus(NH7), .ct_out(AHrs));

    ct_mod_N Dreg (.clk(Pulse), .rst(Reset), .en(ADen),
                   .modulus(ND7), .ct_out(ADay));


    lcd_int Sdisp (.bin_in(TSec),         .Segment1(S1disp), .Segment0(S0disp));
    lcd_int Mdisp (.bin_in(Min),          .Segment1(M1disp), .Segment0(M0disp));
    lcd_int Hdisp (.bin_in(Hrs),          .Segment1(H1disp), .Segment0(H0disp));
    lcd_int Ddisp (.bin_in(Day),          .Segment1(),       .Segment0(D0disp));
    lcd_int Ndisp (.bin_in({3'b0,TMonth}),.Segment1(N1disp), .Segment0(N0disp));
    lcd_int Tdisp (.bin_in({1'b0,TDate}), .Segment1(T1disp), .Segment0(T0disp));


    alarm a1 (.tmin(TMin), .amin(AMin),
              .thrs(THrs), .ahrs(AHrs),
              .tday(TDay), .aday(ADay),
              .buzz(alarm_trigger));

    assign Buzz = alarm_trigger & Alarmon;
endmodule
