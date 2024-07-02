`timescale 1ms / 100 us

module main_tb ();

// Testbench ports
localparam CLK_PERIOD = 10; // 1000 Hz clk
logic tb_clk, tb_nRst, tb_role_switch, tb_red, tb_green, tb_blue, tb_error, tb_msg_sent; //Input
logic [3:0] tb_row_host, tb_row_player;
logic [127:0] tb_play_row1, tb_play_row2, tb_host_row1, tb_host_row2;


// Clock generation block
always begin
    tb_clk = 1'b0; 
    #(CLK_PERIOD / 2.0);
    tb_clk = 1'b1; 
    #(CLK_PERIOD / 2.0); 
end

// Portmap
main main0 (.clk(tb_clk), .nRst(tb_nRst), .role_switch(tb_role_switch), .red(tb_red), .green(tb_green), .blue(tb_blue), .error(tb_error), .play_row1(tb_play_row1), .play_row2(tb_play_row2), .host_row1(tb_host_row1), .host_row2(tb_host_row2), .input_row_player(tb_row_player), .input_row_host(tb_row_host), .msg_sent(tb_msg_sent));


initial begin 
    // Signal dump
    $dumpfile("dump.vcd");
    $dumpvars;

    tb_row_host = 4'd0;
    tb_row_player = 4'd0;
    tb_role_switch = 0;

    // Wait some time before starting first test case
    #(0.1);

    // ***********************************
    // Test Case 0: Power-on-Reset 
    // ***********************************
    #(CLK_PERIOD * 2);
    @(negedge tb_clk);
    tb_nRst = 1'b0; 
    @(negedge tb_clk);
    @(negedge tb_clk);
    tb_nRst = 1'b1;
    @(posedge tb_clk);
    #(CLK_PERIOD * 2);

     // ***********************************
    // Test Case 1: Host Side: Setting the word APPLE 
    // ***********************************

    @(negedge tb_clk);
    tb_row_host = 4'b1000; // R0 C1 -> 'A'

    #(CLK_PERIOD * 20000);

    @(negedge tb_clk);
    tb_row_host = 4'd0;


     @(posedge tb_clk);
    #(CLK_PERIOD * 3000); // R3 C0 (submit_letter_key)
    tb_row_host = 4'b0001;
    #(CLK_PERIOD * 2000)
    @(negedge tb_clk);
    tb_row_host = 4'd0;

    @(negedge tb_clk);
    tb_row_host = 4'b0010; // R2 C0 -> 'P'

    #(CLK_PERIOD * 20000);

    @(negedge tb_clk);
    tb_row_host = 4'd0;


     @(posedge tb_clk);
    #(CLK_PERIOD * 3000); // R3 C0 (submit_letter_key)
    tb_row_host = 4'b0001;
    #(CLK_PERIOD * 2000)
    @(negedge tb_clk);
    tb_row_host = 4'd0;



    @(negedge tb_clk);
    tb_row_host = 4'b0010; // R2 C0 -> 'P'

    #(CLK_PERIOD * 20000);

    @(negedge tb_clk);
    tb_row_host = 4'd0;


     @(posedge tb_clk);
    #(CLK_PERIOD * 3000); // R3 C0 (submit_letter_key)
    tb_row_host = 4'b0001;
    #(CLK_PERIOD * 2000)
    @(negedge tb_clk);
    tb_row_host = 4'd0;

    repeat (1000) @(negedge tb_clk);
    tb_row_host = 4'b0100; // R1 C1 -> 'L'

    #(CLK_PERIOD * 20000);

    @(negedge tb_clk);
    tb_row_host = 4'd0;


     @(posedge tb_clk);
    #(CLK_PERIOD * 3000); // R3 C0 (submit_letter_key)
    tb_row_host = 4'b0001;
    #(CLK_PERIOD * 2000)
    @(negedge tb_clk);
    tb_row_host = 4'd0;

    repeat (2000) @(negedge tb_clk);
    tb_row_host = 4'b1000; // R0 C2 -> 'E'

    #(CLK_PERIOD * 20000);

    @(negedge tb_clk);
    tb_row_host = 4'd0;


     @(posedge tb_clk);
    #(CLK_PERIOD * 3000); // R3 C0 (submit_letter_key)
    tb_row_host = 4'b0001;
    #(CLK_PERIOD * 2000)
    @(negedge tb_clk);
    tb_row_host = 4'd0;

    repeat (2000) @(negedge tb_clk); // R3 C2 (submit_word_key)
    tb_row_host = 4'b0001;
    #(CLK_PERIOD * 2000)
    @(negedge tb_clk);
    tb_row_host = 4'd0;

    #(CLK_PERIOD * 2000)

    $finish;
end
endmodule