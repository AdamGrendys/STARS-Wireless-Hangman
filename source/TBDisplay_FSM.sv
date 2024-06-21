/* Display FSM File
Descriuption: x
*/

`timescale 1ms / 100 us

module tb_display_fsm ();

// Testbench ports
localparam CLK_PERIOD = 10; // 100 Hz clk
logic tb_clk, tb_nRst, tb_ready;
logic [7:0] tb_msg;
logic [127:0] tb_row1, tb_row2;

// Clock generation block
always begin
    tb_clk = 1'b0; 
    #(CLK_PERIOD / 2.0);
    tb_clk = 1'b1; 
    #(CLK_PERIOD / 2.0); 
end

// Portmap
display_fsm tb_disp_fsm(.clk(tb_clk), .nRst(tb_nRst), .ready(tb_ready), .msg(tb_msg), .row1(tb_row1), .row2(tb_row2));

initial begin 
    // Signal dump
    $dumpfile("dump.vcd");
    $dumpvars; 

    // Initialize test bench signals
    tb_nRst = 1'b1;
    tb_ready = 0;
    tb_msg = 8'd5;

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
    #(CLK_PERIOD * 5);

    // ***********************************
    // Test Case 1: Ready Low
    // ***********************************
    tb_ready = 0;
    #(CLK_PERIOD * 5);

    // ***********************************
    // Test Case 2: Ready High
    // ***********************************
    tb_ready = 1;
    #(CLK_PERIOD * 5);

end
endmodule