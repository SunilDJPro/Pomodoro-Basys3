module timer_control(
    input wire clk_1Hz,
    input wire rst,
    input wire break_mode,
    input wire start_pause,
    output reg [7:0] minutes,
    output reg [7:0] seconds,
    output reg timer_done,
    output reg blink_out,
    output reg timer_running    // Added output signal
);

    reg start_pause_prev;
    
    // Initialize timer values
    always @(posedge clk_1Hz or posedge rst) begin
        if (rst) begin
            minutes <= break_mode ? 8'd5 : 8'd25;
            seconds <= 8'd0;
            timer_running <= 1'b0;
            timer_done <= 1'b0;
            blink_out <= 1'b0;
            start_pause_prev <= 1'b0;
        end
        else begin
            // Handle start/pause button
            if (start_pause && !start_pause_prev)
                timer_running <= ~timer_running;
            start_pause_prev <= start_pause;
            
            // Handle break mode change
            if (break_mode && minutes > 8'd5)
                minutes <= 8'd5;
            else if (!break_mode && !timer_running && minutes < 8'd25)
                minutes <= 8'd25;
                
            // Timer countdown logic
            if (timer_running && !timer_done) begin
                if (seconds == 0) begin
                    if (minutes == 0) begin
                        timer_done <= 1'b1;    // Set timer_done for both normal and break modes
                        timer_running <= 1'b0;
                    end
                    else begin
                        minutes <= minutes - 1;
                        seconds <= 8'd59;
                    end
                end
                else begin
                    seconds <= seconds - 1;
                end
            end
            
            // Reset timer_done only when changing modes or starting a new timer
            if ((break_mode && minutes == 5 && seconds == 0 && !timer_running) ||
                (!break_mode && minutes == 25 && seconds == 0 && !timer_running)) begin
                timer_done <= 1'b0;
            end
            
            // Generate blinking signal when timer is done
            if (timer_done)
                blink_out <= ~blink_out;
        end
    end

endmodule