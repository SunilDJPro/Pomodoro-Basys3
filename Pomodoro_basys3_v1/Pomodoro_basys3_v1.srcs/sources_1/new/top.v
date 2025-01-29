module top(
    input wire CLK100MHZ,    // Basys 3 main clock
    input wire BTNC,         // Center button for reset
    input wire BTNU,         // Up button for start/pause
    input wire BTNR,         // Right button for start/pause (redundant)
    input wire [15:0] SW,    // Switches (SW0 for break mode)
    output wire [15:0] LED,  // LEDs (LED0 for break mode indicator)
    output wire [6:0] SEG,   // Seven segment segments
    output wire DP,          // Decimal point (for colon)
    output wire [3:0] AN     // Seven segment anodes
);

    // Internal signals
    wire clk_1Hz;
    wire clk_1kHz;
    wire [7:0] minutes;
    wire [7:0] seconds;
    wire timer_done;
    wire blink_signal;
    wire start_pause;
    wire timer_running;      // Added for colon blinking control
    
    // LED Control
    assign LED[0] = SW[0];         // LED0 indicates break mode
    assign LED[15:1] = timer_done ? {15{blink_signal}} : 15'b0;  // LEDs 1-15 blink when timer done
    
    // Combine start/pause buttons
    assign start_pause = BTNU | BTNR;
    
    // Clock divider instance
    clock_divider clk_div(
        .clk_100MHz(CLK100MHZ),
        .rst(BTNC),
        .clk_1Hz(clk_1Hz),
        .clk_1kHz(clk_1kHz)
    );
    
    // Timer control instance
    timer_control timer(
        .clk_1Hz(clk_1Hz),
        .rst(BTNC),
        .break_mode(SW[0]),
        .start_pause(start_pause),
        .minutes(minutes),
        .seconds(seconds),
        .timer_done(timer_done),
        .blink_out(blink_signal),
        .timer_running(timer_running)    // New output signal
    );
    
    // Seven segment display controller instance
    seven_seg_ctrl display(
        .clk_1kHz(clk_1kHz),
        .clk_1Hz(clk_1Hz),
        .rst(BTNC),
        .minutes(minutes),
        .seconds(seconds),
        .timer_running(timer_running),
        .seg(SEG),
        .dp(DP),
        .an(AN)
    );

endmodule