`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/12/2015 03:26:51 PM
// Design Name: 
// Module Name: // Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
 
module top (
    input SYSCLK,
    input RST_N,
    input LEVER,

    output        GPIO,
    output [6:0]  SEG, 
    output [3:0]  AN
);

    ///////////////////////////////////////////////////////////////////////////
    // Clock input
    ///////////////////////////////////////////////////////////////////////////
    wire clk;

    assign clk = SYSCLK;

    ///////////////////////////////////////////////////////////////////////////
    // Synchronize async reset using reset bridge
    ///////////////////////////////////////////////////////////////////////////
    reg  rst_n    = 1'b0;
    reg  rst_n_q1 = 1'b0;

    always @(posedge clk or negedge RST_N) begin
        if (!RST_N) begin
            {rst_n, rst_n_q1} <= 2'b0;
        end else begin
            {rst_n, rst_n_q1} <= {rst_n_q1, 1'b1};
        end
    end

    ///////////////////////////////////////////////////////////////////////////
    // Debounce lever input
    ///////////////////////////////////////////////////////////////////////////
    wire lever_pulse;

    debouncer lever_debounce (
        .clk           (clk),
        .signal_in     (LEVER),
        .deb_pulse_out (lever_pulse)
    );

    ///////////////////////////////////////////////////////////////////////////
    // Timer Engine
    ///////////////////////////////////////////////////////////////////////////
    wire [7:0] min_bcd;
    wire [7:0] sec_bcd;
    wire blink_7sd;

    timer_engine timer_engine (
        .clk        (clk),
        .rst_n      (rst_n),
        .lever      (lever_pulse),
        .min_bcd    (min_bcd),
        .sec_bcd    (sec_bcd),
        .blink_7sd  (blink_7sd)
    );
    
    ///////////////////////////////////////////////////////////////////////////
    // Seven Segment Display
    ///////////////////////////////////////////////////////////////////////////
    wire [3:0] an_out;

    seven_seg_disp seven_seg_disp (
        .clk (clk),
        .x   ({min_bcd, sec_bcd}),
        .seg (SEG),
        .an  (an_out)
    );

    // Blink 7SD digits 
    assign AN = blink_7sd ? 4'b1111 : {an_out[0], an_out[1], an_out[2], an_out[3]};
    
    // GPIO pin blue-wired on board to 7SD "Cathode DP" pin
    assign GPIO = 1'b0; 
 
endmodule
