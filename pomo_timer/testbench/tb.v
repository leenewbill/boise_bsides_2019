module tb;

    parameter SYSCLK_PERIOD = 10; // 10 ns = 100 MHz

    // input signals to the test module
    reg sysclk = 1'b0;
    reg rstn   = 1'b0;
    reg btnu   = 1'b0;
//    reg btnc   = 1'b0;
//    reg btnd   = 1'b0;

    // output signals from the test module
//    wire cs_n;
//    wire mosi;
    wire sclk;
//    wire [15:0] led;

    // testbench signals and variables
    integer i = 0;
    integer j = 0;

    // DUT instantiation
    top dut
    (
        .SYSCLK        (sysclk),
        .RSTN          (rstn),
//        .SW            ('b0),
        .BTNU          (btnu),
//        .BTNC          (btnc),
//        .BTND          (btnd),
//        .STMPE610_CS_N (cs_n),
//        .MOSI          (mosi),
//        .SCLK          (sclk),
        .LED           (led)
    );


    // generate system clock
    initial sysclk = 1'b0;
    
    always #(SYSCLK_PERIOD / 2.0) sysclk = ~sysclk;

    // generate reset
    initial rstn = 1'b0;

    always @(posedge sysclk)
    begin
        i = i + 1;

        if (i == 10)
        begin
            #1 rstn <= 1'b1;
        end
    end


    // DUT stimulus
    initial
    begin
 /*
        {btnc, btnu, btnd} = 3'b000;

        wait (rstn == 1'b0);
        wait (rstn == 1'b1);
        
        for (j = 0; j < 20; j = j + 1) @(posedge sysclk);

        {btnc, btnu, btnd} = 3'b100;

        for (j = 0; j < 20; j = j + 1) @(posedge sysclk);

        {btnu, btnc, btnd} = 3'b000;

        for (j = 0; j < 400; j = j + 1) @(posedge sysclk);

        {btnc, btnu, btnd} = 3'b010;

        for (j = 0; j < 20; j = j + 1) @(posedge sysclk);

        {btnc, btnu, btnd} = 3'b000;

        for (j = 0; j < 400; j = j + 1) @(posedge sysclk);

        {btnc, btnu, btnd} = 3'b001;

        for (j = 0; j < 20; j = j + 1) @(posedge sysclk);

        {btnc, btnu, btnd} = 3'b000;

        for (j = 0; j < 400; j = j + 1) @(posedge sysclk);

        {btnc, btnu, btnd} = 3'b010;

        for (j = 0; j < 20; j = j + 1) @(posedge sysclk);

        forever @(posedge sysclk) {btnc, btnu, btnd} = 3'b000;
*/
    end

endmodule

