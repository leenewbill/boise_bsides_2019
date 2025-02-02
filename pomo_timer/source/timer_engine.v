
module timer_engine (
    input clk,
    input rst_n,
    input lever,
    input button,

    output reg [7:0] min_bcd,
    output reg [7:0] sec_bcd,
    output reg       blink_7sd
);

    `include "defs.vh"

    ///////////////////////////////////////////////////////////////////////
    // Pomodoro Timer - Finite State Machine
    ///////////////////////////////////////////////////////////////////////
    localparam  IDLE_st           = 8'b00000001;
    localparam  TIMER_START_st    = 8'b00000010;
    localparam  SET_MINUTES_st    = 8'b00000100;
    //localparam  SET_SECONDS_st    = 8'b00001000;
    localparam  BLINK_7SD_st      = 8'b00001000;
    //localparam  BLINK_7SD_st      = 8'b00010000;

    reg  [22:0] clk_cnt = 'b0;
    reg  [7:0]  minutes = 'd25;
    reg  [7:0]  seconds = 'd0;
    reg         update_bcd = 1'b1;

    reg  [7:0]  state = IDLE_st;

    always @(posedge clk) begin
        if (!rst_n)
        begin
            clk_cnt <= 'b0;
            minutes <= 'd25;
            seconds <= 'd0;
            update_bcd <= 1'b1;
            blink_7sd <= 1'b0;

            state <= IDLE_st;
        end
        else
        begin
            // default values
            update_bcd <= 1'b0;
            blink_7sd <= 1'b0;

            case (state)
                IDLE_st: begin
                    if (lever) begin
                        state <= TIMER_START_st;
                    end else if (button) begin
                        state <= SET_MINUTES_st;
                    end
                end

                TIMER_START_st: begin
                    if (lever) begin
                        state <= IDLE_st;
                    end else begin
                        if (minutes == 0 && seconds == 0) begin
                            clk_cnt <= 'b0;

                            state <= BLINK_7SD_st;
                        end else if (clk_cnt >= MAX_CLKS) begin
                            if (seconds == 0) begin
                                minutes <= minutes - 1;
                                seconds <= 'd59;
                            end else begin
                                seconds <= seconds - 1;
                            end
                            
                            clk_cnt <= 'b0;
                            update_bcd <= 1'b1;
                        end else begin
                            clk_cnt <= clk_cnt + 1;
                        end
                    end
                end

                SET_MINUTES_st: begin
                    if (lever) begin
                        if (minutes == 0) begin
                            minutes <= 'd59;
                        end else begin
                            minutes <= minutes - 1;
                        end

                        update_bcd <= 1'b1;
                    end else if (button) begin
                        state <= IDLE_st;
                        //state <= SET_SECONDS_st;
                    end

                    if (clk_cnt >= 500000) begin
                    //if (clk_cnt >= 1000000) begin
                        clk_cnt <= 'b0;
                        blink_7sd <= ~blink_7sd;
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                        blink_7sd <= blink_7sd;
                    end
                end
/*
                SET_SECONDS_st: begin
                    if (lever) begin
                        if (seconds == 0) begin
                            seconds <= 'd59;
                        end else begin
                            seconds <= seconds - 1;
                        end

                        update_bcd <= 1'b1;
                    end else if (button) begin
                        state <= IDLE_st;
                    end

                    if (clk_cnt >= 1000000) begin
                        clk_cnt <= 'b0;
                        blink_7sd <= ~blink_7sd;
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                        blink_7sd <= blink_7sd;
                    end
                end
*/
                BLINK_7SD_st: begin
/*
                    if (button) begin
                        state <= IDLE_st;
                    end
*/
                    if (clk_cnt >= 500000) begin
                    //if (clk_cnt >= 1000000) begin
                        clk_cnt <= 'b0;
                        blink_7sd <= ~blink_7sd;
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                        blink_7sd <= blink_7sd;
                    end

                end

                default: begin
                    state <= IDLE_st;
                end
            endcase
        end
    end

    ///////////////////////////////////////////////////////////////////////
    // Convert binary values to BCD
    ///////////////////////////////////////////////////////////////////////
    wire [7:0] min_bcd_o;
    wire [7:0] sec_bcd_o;
    wire       min_bcd_done;
    wire       sec_bcd_done;

    // Convert minutes to BCD
    binary_to_bcd #(
        .BITS_IN_PP        (8),
        .BCD_DIGITS_OUT_PP (2)
    ) min_binary_to_bcd (
        .clk_i        (clk),
        .ce_i         (1'b1),
        .rst_i        (~rst_n),
        .start_i      (update_bcd),
        .dat_binary_i (minutes),
        .dat_bcd_o    (min_bcd_o),
        .done_o       (min_bcd_done)
    );
    
    always @(posedge clk) begin
        if (min_bcd_done) begin
            min_bcd <= min_bcd_o;
        end
    end
    
    // Convert seconds to BCD
    binary_to_bcd #(
        .BITS_IN_PP        (8),
        .BCD_DIGITS_OUT_PP (2)
    ) sec_binary_to_bcd (
        .clk_i        (clk),
        .ce_i         (1'b1),
        .rst_i        (~rst_n),
        .start_i      (update_bcd),
        .dat_binary_i (seconds),
        .dat_bcd_o    (sec_bcd_o),
        .done_o       (sec_bcd_done)
    );
    
    always @(posedge clk) begin
        if (sec_bcd_done) begin
            sec_bcd <= sec_bcd_o;
        end
    end
    
endmodule
