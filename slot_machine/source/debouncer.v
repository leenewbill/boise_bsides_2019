module debouncer
(
    input clk,
    input signal_in,
    
    output reg deb_pulse_out
);

    reg sig_q     = 1'b0;
    reg sig_qq    = 1'b0;

    reg [19:0] clk_cnt = 'b0;
    reg        busy    = 1'b0;


    // Synchronize input signal
    always @(posedge clk)
    begin
        {sig_qq, sig_q} <= {sig_q, signal_in};
    end
    
    // Create debounced signal pulse
    always @(posedge clk)
    begin
        // default values
        deb_pulse_out <= 1'b0;
        
        // only look for input signal if we are not already counting clocks
        if (!busy)
        begin
            if (!sig_qq & sig_q)  // look for the first rising edge of the input signal
            begin
                deb_pulse_out <= 1'b1;  // generate signal event pulse

                busy <= 1'b1;  // start counting clocks
            end
        end
        else 
        begin
            if (&clk_cnt)
            begin
                busy <= 1'b0;
            end

            clk_cnt <= clk_cnt + 1;
        end
    end

endmodule

