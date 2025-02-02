module reel
(
//    input       clk,
//    input       spin_en,
    input [5:0] v_reel,

//    output reg [3:0] p_reel,
    output reg [3:0] symbol
);

    `include "defs.vh"
/*
    always @(*)
    begin
        if (v_reel >= 3 && v_reel < 10)  // 7
        begin
            symbol = LIME;
        end
        else if (v_reel >= 11 && v_reel < 16)  // 5
        begin
            symbol = BANANA;
        end
        else if (v_reel >= 17 && v_reel < 22)  // 5
        begin
            symbol = ORANGE;
        end
        else if (v_reel >= 23 && v_reel < 30)  // 7
        begin
            symbol = GRAPE;
        end
        else if (v_reel >= 31 && v_reel < 37)  // 6
        begin
            symbol = LIME;
        end
        else if (v_reel >= 38 && v_reel < 41)  // 3
        begin
            symbol = BLUEBERRY;
        end
        else if (v_reel >= 42 && v_reel < 47)  // 5
        begin
            symbol = ORANGE;
        end
        else if (v_reel == 48)  // 1
        begin
            symbol = CHERRY;
        end
        else
        begin
            symbol = BLANK;
        end
    end
*/
    always @(*)
    begin
        if (v_reel >= 3 && v_reel < 10)  // 7
        begin
//            p_reel = 1;
            symbol = LIME;
        end
        else if (v_reel >= 13 && v_reel < 18)  // 5
        begin
//            p_reel = 3;
            symbol = BANANA;
        end
        else if (v_reel >= 21 && v_reel < 26)  // 5
        begin
//            p_reel = 5;
            symbol = ORANGE;
        end
        else if (v_reel >= 29 && v_reel < 36)  // 7
        begin
//            p_reel = 7;
            symbol = GRAPE;
        end
        else if (v_reel >= 39 && v_reel < 45)  // 6
        begin
//            p_reel = 9;
            symbol = LIME;
        end
        else if (v_reel >= 48 && v_reel < 51)  // 3
        begin
//            p_reel = 11;
            symbol = BLUEBERRY;
        end
        else if (v_reel >= 54 && v_reel < 59)  // 5
        begin
//            p_reel = 13;
            symbol = ORANGE;
        end
        else if (v_reel == 63)  // 1
        begin
            symbol = CHERRY;
        end
        else
        begin
            symbol = BLANK;
        end
    end

endmodule

