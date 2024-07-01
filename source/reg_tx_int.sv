/* UART Transmitter + Message Register Integration Test
Descriuption: x
*/

`timescale 1ms / 100 us

module reg_tx_int ();

// Testbench ports
localparam CLK_PERIOD = 10; // 100 Hz clk
logic tb_clk, tb_nRst, tb_ready, tb_transmit_ready, tb_blue, tb_tx_ctrl, tb_tx_serial;
logic [7:0] tb_msg, tb_tx_byte;

// Clock generation block
always begin
    tb_clk = 1'b0; 
    #(CLK_PERIOD / 2.0);
    tb_clk = 1'b1; 
    #(CLK_PERIOD / 2.0); 
end

// Portmap
INT_TOP_Reg_Tx mesgsgs (.tb_clk(tb_clk), .tb_nRst(tb_nRst), .tb_tx_serial(tb_tx_serial), .tb_ready(tb_ready), .tb_blue(tb_blue), .tb_tx_ctrl(tb_tx_ctrl), .tb_msg(tb_msg), .tb_tx_byte(tb_tx_byte), .tb_transmit_ready(tb_transmit_ready));

initial begin 
    // Signal dump
    $dumpfile("dump.vcd");
    $dumpvars; 

    // Initialize test bench signals
    tb_ready = 0;
    tb_msg = 0;

    // Wait some time before starting first test case
    #(0.1);

    // ***********************************
    // Test Case 0: Power-on-Reset 
    // ***********************************
    #(CLK_PERIOD * 1000);
    @(negedge tb_clk);
    tb_nRst = 1'b0; 
    @(negedge tb_clk);
    @(negedge tb_clk);
    tb_nRst = 1'b1;
    @(posedge tb_clk);
    #(CLK_PERIOD * 1000);

     // ***********************************
    // Test Case 0: Power-on-Reset 
    // ***********************************

    tb_ready = 0;
    tb_msg = 8'b10101011;
    #(CLK_PERIOD * 6500);

    tb_ready = 1;
    #(CLK_PERIOD * 7500);

    tb_msg = 8'b01101101;
    #(CLK_PERIOD * 12000);
    tb_ready = 0;
    #(CLK_PERIOD * 10000);



    
    $finish;

end
endmodule