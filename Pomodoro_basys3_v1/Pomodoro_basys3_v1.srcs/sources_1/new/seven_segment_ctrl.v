module seven_seg_ctrl(
    input wire clk_1kHz,
    input wire clk_1Hz,    // For colon blinking
    input wire rst,
    input wire [7:0] minutes,
    input wire [7:0] seconds,
    input wire timer_running,  // For colon blinking
    output reg [6:0] seg,
    output reg dp,            // Decimal point for colon
    output reg [3:0] an
);

    reg [3:0] digit_data;
    reg [1:0] digit_sel;
    wire colon_state;
    
    // Generate blinking colon using 1Hz clock when timer is running
    assign colon_state = timer_running ? clk_1Hz : 1'b0;
    
    // BCD to Seven Segment decoder
    always @(*) begin
        case(digit_data)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111;
        endcase
    end
    
    // Digit multiplexing
    always @(posedge clk_1kHz or posedge rst) begin
        if (rst)
            digit_sel <= 2'b00;
        else
            digit_sel <= digit_sel + 1;
    end
    
    // Digit selection and anode control
    always @(*) begin
        case(digit_sel)
            2'b11: begin  // Leftmost digit
                digit_data = minutes / 10;
                an = 4'b0111;
                dp = 1'b1;  // No dot
            end
            2'b10: begin  // Second digit
                digit_data = minutes % 10;
                an = 4'b1011;
                dp = ~colon_state;  // Blinking colon
            end
            2'b01: begin  // Third digit
                digit_data = seconds / 10;
                an = 4'b1101;
                dp = 1'b1;  // No dot
            end
            2'b00: begin  // Rightmost digit
                digit_data = seconds % 10;
                an = 4'b1110;
                dp = 1'b1;  // No dot
            end
        endcase
    end

endmodule