
module sm_engine
(
    input clk,
    input rst_n,
    input lever,

    //output reg [15:0] bal_bcd,
    output reg        win,
    output reg        win_blink,
    output     [11:0] symbols
);

    `include "defs.vh"

    localparam  IDLE_st           = 8'b00000001;
    localparam  GET_SYMBOLS_st    = 8'b00000010;
    localparam  CALC_PAYOUT_st    = 8'b00000100;
    localparam  ANIMATION_st      = 8'b00001000;

    reg  [18:0] clk_cnt     = 'b0;
    reg         clk_cnt_rst = 1'b1;

    reg  [17:0] v_reel_rng = 'b0;

    reg  [5:0]  v_reel [2:0];
    wire [3:0]  p_reel [2:0];
    wire [3:0]  symbol [2:0];

    reg  [15:0] balance = 'd1000;

    reg         update_bcd = 1'b1;

    wire [15:0] dat_bcd_o;
    wire        bcd_done;

    reg  [7:0]  state = IDLE_st;


    ///////////////////////////////////////////////////////////////////////
    //
    ///////////////////////////////////////////////////////////////////////
    always @(posedge clk)
    begin
        if (clk_cnt_rst)
        begin
            clk_cnt <= 'b0;
        end
        else
        begin
            clk_cnt <= clk_cnt + 1;
        end
    end


    always @(posedge clk)
    begin
        v_reel_rng <= v_reel_rng + 1;
    end


    ///////////////////////////////////////////////////////////////////////
    // SLOT MACHINE - FINITE STATE MACHINE
    ///////////////////////////////////////////////////////////////////////
    always @(posedge clk)
    begin
        if (!rst_n)
        begin
            //balance <= 'd1000;

            //update_bcd <= 1'b1;

            {v_reel[2], v_reel[1], v_reel[0]} <= 'b0;

            clk_cnt_rst <= 1'b1;
            win         <= 1'b0;
            win_blink   <= 1'b0;

            state <= IDLE_st;
        end
        else
        begin
            // default values
            clk_cnt_rst <= 1'b1;
            //update_bcd <= 1'b0;

            case (state)
                IDLE_st:
                begin
                    if (lever)
                    begin
                        win_blink <= 1'b0;

                        //balance <= balance - 1;

                        {v_reel[2], v_reel[1], v_reel[0]} <= v_reel_rng;

                        state <= GET_SYMBOLS_st;
                    end
                    else if (win)
                    begin
                        clk_cnt_rst <= 1'b0;

                        if (&clk_cnt)
                        begin
                            win_blink <= ~win_blink;
                        end
                    end
                end

                GET_SYMBOLS_st:  // pipeline stage
                begin
                    state <= CALC_PAYOUT_st;
                end

                CALC_PAYOUT_st:
                begin
                    //calc_payout();
                    win <= ((symbol[0] == symbol[1]) && (symbol[0] == symbol[2]) && (symbol[0] != BLANK));

                    state <= ANIMATION_st;
                end

                ANIMATION_st:
                begin
                    clk_cnt_rst <= 1'b0;
                    //update_bcd <= 1'b1;

                    if (&clk_cnt)
                    begin
                        state <= IDLE_st;
                    end
/*
                    if (clk_cnt < MAX_CLKS)
                    begin
                        clk_cnt <= clk_cnt + 1;
                    end
                    else
                    begin
                        clk_cnt <= 'b0;  // reset counter

                        state <= IDLE_st;
                    end
*/
                end

                default:
                begin
                    state <= IDLE_st;
                end
            endcase
        end
    end


    reel reel0
    (
//        .clk    (clk),
        .v_reel (v_reel[0]),
//        .p_reel (p_reel[0]),
        .symbol (symbol[0])
    );

    reel reel1
    (
//        .clk    (clk),
        .v_reel (v_reel[1]),
//        .p_reel (p_reel[1]),
        .symbol (symbol[1])
    );

    reel reel2
    (
//        .clk    (clk),
        .v_reel (v_reel[2]),
//        .p_reel (p_reel[2]),
        .symbol (symbol[2])
    );

    assign symbols = {symbol[2], symbol[1], symbol[0]};

/*
    binary_to_bcd 
    #(
        .BCD_DIGITS_OUT_PP (4)
    )
    binary_to_bcd
    (
        .clk_i        (clk),
        .ce_i         (1'b1),
        .rst_i        (~rst_n),
        .start_i      (update_bcd),
        .dat_binary_i (balance),
        .dat_bcd_o    (dat_bcd_o),
        .done_o       (bcd_done)
    );

    
    always @(posedge clk)
    begin
        if (bcd_done)
        begin
            bal_bcd <= dat_bcd_o;
        end
    end

    task calc_payout;
    begin
        if ((symbol[0] == CHERRY) && (symbol[1] == CHERRY) && (symbol[2] == CHERRY))
        begin
            balance <= {4'd5, 4'd0, 4'd0, 4'd0};
            //balance <= balance + 5000;
        end
        else if ((symbol[0] == BLUEBERRY) && (symbol[1] == BLUEBERRY) && (symbol[2] == BLUEBERRY))
        begin
            balance <= {4'd1, 4'd0, 4'd0, 4'd0};
            //balance <= balance + 1000;
        end
        else if ((symbol[0] == BANANA) && (symbol[1] == BANANA) && (symbol[2] == BANANA))
        begin
            balance <= {4'd0, 4'd5, 4'd0, 4'd0};
            //balance <= balance + 500;
        end
        else if ((symbol[0] == GRAPE) && (symbol[1] == GRAPE) && (symbol[2] == GRAPE))
        begin
            balance <= {4'd0, 4'd1, 4'd0, 4'd0};
            //balance <= balance + 100;
        end
        else if ((symbol[0] == ORANGE) && (symbol[1] == ORANGE) && (symbol[2] == ORANGE))
        begin
            balance <= {4'd0, 4'd0, 4'd2, 4'd5};
            //balance <= balance + 25;
        end
        else if ((symbol[0] == LIME) && (symbol[1] == LIME) && (symbol[2] == LIME))
        begin
            balance <= {4'd0, 4'd0, 4'd1, 4'd0};
            //balance <= balance + 10;
        end
        else
        begin
            balance <= 'b0;
        end

        else if (((symbol[0] == CHERRY) && (symbol[1] == CHERRY)) || 
                 ((symbol[0] == CHERRY) && (symbol[2] == CHERRY)) ||
                 ((symbol[1] == CHERRY) && (symbol[2] == CHERRY))) 
        begin
            balance <= balance + 50;
        end
        else if ((symbol[0] == CHERRY) || (symbol[1] == CHERRY) || (symbol[2] == CHERRY))
        begin
            balance <= balance + 5;
        end
        else if ((symbol[0] != BLANK) && (symbol[1] != BLANK) && (symbol[2] != BLANK))
        begin
            balance <= balance + 1;
        end
    end
    endtask

*/    
endmodule
