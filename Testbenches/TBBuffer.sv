/* Buffer File
Descriuption: x
*/

`timescale 1ms / 100 us

module tb_buffer ();

// Testbench ports
localparam CLK_PERIOD = 10; // 100 Hz clk
logic tb_clk, tb_nRst, tb_ready, tb_game_rdy;
logic [7:0] tb_byte;

// Clock generation block
always begin
    tb_clk = 1'b0; 
    #(CLK_PERIOD / 2.0);
    tb_clk = 1'b1; 
    #(CLK_PERIOD / 2.0); 
end

// Portmap 
buffer buffertest(.clk(tb_clk), .nRst(tb_nRst), .ready(tb_ready), .Rx_byte(tb_byte), .game_rdy(tb_game_rdy), .guess(tb_guess));


initial begin 
    // Signal dump
    $dumpfile("dump.vcd");
    $dumpvars; 

    // Initialize test bench signals
    tb_nRst = 1'b1;
    tb_byte = 8'd5;

    // Wait some time before starting first test case
    #(0.1);

    // ***********************************
    // Test Case 0: Power-on-Reset 
    // ***********************************
    #10;
    @(negedge tb_clk);
    tb_nRst = 1'b0; 
    @(negedge tb_clk);
    @(negedge tb_clk);
    tb_nRst = 1'b1;
    @(posedge tb_clk);
    #10;

    // ***********************************
    // Test Case 0: Ready High, Game Ready Low
    // ***********************************
    tb_ready = 1;
    tb_game_rdy = 0;
    #(CLK_PERIOD * 2);


    // ***********************************
    // Test Case 0: Ready Low, Game Ready High
    // ***********************************
    tb_ready = 0;
    tb_game_rdy = 1;
    #(CLK_PERIOD * 2);

    // ***********************************
    // Test Case 0: Ready High, Game Ready High
    // ***********************************
    tb_ready = 1;
    tb_game_rdy = 1;
    #(CLK_PERIOD * 2);

    $finish;
end
    
endmodule