`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Thomas Kappenman
// 
// Create Date:    03/03/2015 09:08:33 PM 
// Design Name: 
// Module Name:    seg7decimal 
// Project Name: Nexys4DDR Keyboard Demo
// Target Devices: Nexys4DDR
// Tool Versions: 
// Description: 7 segment display driver
// 
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module seven_seg_disp
(
    input        clk,
    input [15:0] x,

    output reg [6:0] seg,
    output reg [3:0] an
);
     
    wire [2:0]  s;   
    reg  [3:0]  digit;
    wire [3:0]  aen;
    reg  [13:0] clkdiv;
    //reg  [19:0] clkdiv;

    assign s = clkdiv[13:11];
    //assign s = clkdiv[19:17];
    assign aen = 4'b1111; // all turned off initially


    always @(posedge clk)
    begin   
        case (s)
            0: digit = x[3:0];   // s is 00 --> 0 ;  digit gets assigned 4 bit value assigned to x[3:0]
            1: digit = x[7:4];   // s is 01 --> 1 ;  digit gets assigned 4 bit value assigned to x[7:4]
            2: digit = x[11:8];  // s is 10 --> 2 ;  digit gets assigned 4 bit value assigned to x[11:8
            3: digit = x[15:12]; // s is 11 --> 3 ;  digit gets assigned 4 bit value assigned to x[15:12]
            
            default: digit = x[3:0];
        endcase
    end    

    // decoder or truth-table for 7seg display values
    always @(*)
    begin
        case (digit)
            0:   seg = 7'b1000000;
            1:   seg = 7'b1111001;
            2:   seg = 7'b0100100;
            3:   seg = 7'b0110000;
            4:   seg = 7'b0011001;
            5:   seg = 7'b0010010;
            6:   seg = 7'b0000010;
            7:   seg = 7'b1111000;
            8:   seg = 7'b0000000;
            9:   seg = 7'b0010000;

            default: seg = 7'b0000000;
        endcase
    end

    always @(*)
    begin
        an = 4'b1111;

        if (aen[s] == 1)
        begin
            an[s] = 0;
        end
    end


    // clkdiv
    always @(posedge clk) 
    begin
        clkdiv <= clkdiv + 1;
    end

endmodule
