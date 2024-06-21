/* Buffer File
Descriuption: x
*/

`timescale 1ms / 100 us

module tb_buffer ();

// Testbench ports
localparam CLK_PERIOD = 10; // 100 Hz clk
logic tb_clk, tb_nRst;

// Clock generation block
always begin
    tb_clk = 1'b0; 
    #(CLK_PERIOD / 2.0);
    tb_clk = 1'b1; 
    #(CLK_PERIOD / 2.0); 
end

// Portmap 
buffer buffertest (.clk(tb_clk), .nRst(tb_nRst), .ready(tb_ready), .game_rdy(tb_game_rdy), .guess(tb_guess));

initial begin 
    // Signal dump
    $dumpfile("dump.vcd");
    $dumpvars; 

    // Initialize test bench signals
    tb_nRst = 1'b1;

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



// ***********************************
// Test Case 0: Ready Low, Game Ready High
// ***********************************


// ***********************************
// Test Case 0: Ready High, Game Ready High
// ***********************************


    $finish;
end
    
endmodule