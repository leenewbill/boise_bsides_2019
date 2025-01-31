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
 
module top
(
    input SYSCLK,
    input RST_N,
//    input BUTT1,
    input LEVER,

//    output        GPIO,
    output [6:0]  SEG, 
//    output [3:0]  AN//,
    output [2:0]  AN//,
//    output        RGB_LED_DAT,
//    output [15:0] LED
);

    wire clk;
         
    reg  rst_n    = 1'b0;
    reg  rst_n_q1 = 1'b0;

//    wire butt1_pulse;
    wire lever_pulse;
                
    wire [15:0] balance;
    wire [11:0] symbols;

    reg         disp_bal_sym = 1'b0;

    wire [15:0] bal_bcd;

    //wire [15:0] disp_data;
    wire [11:0] disp_data;

    wire        win;
    wire        win_blink;

    wire [2:0]  an_out;
    //wire [3:0]  an_out;


    ///////////////////////////////////////////////////////////////////////
    // HANDLE INPUTS
    ///////////////////////////////////////////////////////////////////////
    assign clk = SYSCLK;

    // Synchronize async reset using reset bridge
    always @(posedge clk or negedge RST_N)
    begin
        if (!RST_N)
        begin
            {rst_n, rst_n_q1} <= 2'b0;
        end
        else
        begin
            {rst_n, rst_n_q1} <= {rst_n_q1, 1'b1};
        end
    end
/*
    // Debounce button input
    debouncer butt1_debounce
    (
        .clk           (clk),
        .signal_in     (BUTT1),
        .deb_pulse_out (butt1_pulse)
    );
*/
    // Debounce lever input
    debouncer lever_debounce
    (
        .clk           (clk),
        .signal_in     (LEVER),
        .deb_pulse_out (lever_pulse)
    );


    ///////////////////////////////////////////////////////////////////////
    // MODULE DECLARATIONS
    ///////////////////////////////////////////////////////////////////////
    sm_engine sm_engine
    (
        .clk        (clk),
        .rst_n      (rst_n),
        .lever      (lever_pulse),
        //.lever      (lever_pulse | butt1_pulse),
        .win        (win),
        .win_blink  (win_blink),
        //.bal_bcd    (bal_bcd),
        .symbols    (symbols)
    );
    
/*
    always @(posedge clk)
    begin
        if (butt1_pulse)
        begin
            disp_bal_sym <= ~disp_bal_sym;
        end 
    end

    assign disp_data = disp_bal_sym ? bal_bcd : {4'h0, symbols};
*/

    seven_seg_disp seven_seg_disp
    (
        .clk (clk),
        .x   (symbols),
        .seg (SEG),
        //.an  (AN)
        //.x   (disp_data),
        //.seg (),
        .an  (an_out)
    );
 

    ///////////////////////////////////////////////////////////////////////
    // ASSIGN OUTPUTS
    ///////////////////////////////////////////////////////////////////////

//    assign GPIO = LEVER;

    assign AN = win_blink ? 3'b111 : an_out;
//    assign AN = disp_bal_sym ? an_out : {an_out[2:0], 1'b1};
//    assign AN = disp_bal_sym ? {4'b1111, an_out} : {5'b11111, an_out[2:0]}; // Nexys board only
//    assign AN  = BUTT1 ? 4'hF : 4'h0;
//    assign SEG = LEVER ? 4'hF : 4'h0;
/*
    reg [3:0] butt1_pulse_cnt = 'b0;

    always @(posedge clk)
    begin
        //if (butt1_pulse)
        if (lever_pulse)
        begin
            butt1_pulse_cnt <= butt1_pulse_cnt + 1;
        end
    end

    assign AN = butt1_pulse_cnt; 
    assign SEG = 7'b0000000;
*/
endmodule
