module clock_divider(
    input wire clk_100MHz,
    input wire rst,
    output reg clk_1Hz,
    output reg clk_1kHz    // For seven segment display refresh
);

    // For 1Hz clock
    reg [26:0] count_1Hz;
    // For 1kHz clock (seven segment refresh)
    reg [16:0] count_1kHz;
    
    // Generate 1Hz clock
    always @(posedge clk_100MHz or posedge rst) begin
        if (rst) begin
            count_1Hz <= 0;
            clk_1Hz <= 0;
        end
        else begin
            if (count_1Hz == 49_999_999) begin
                count_1Hz <= 0;
                clk_1Hz <= ~clk_1Hz;
            end
            else
                count_1Hz <= count_1Hz + 1;
        end
    end
    
    // Generate 1kHz clock for display refresh
    always @(posedge clk_100MHz or posedge rst) begin
        if (rst) begin
            count_1kHz <= 0;
            clk_1kHz <= 0;
        end
        else begin
            if (count_1kHz == 49_999) begin
                count_1kHz <= 0;
                clk_1kHz <= ~clk_1kHz;
            end
            else
                count_1kHz <= count_1kHz + 1;
        end
    end

endmodule