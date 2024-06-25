/* UART Transmitter + Message Register Integration Test
Descriuption: x
*/

`timescale 1ms / 100 us

module INT_Reg_UART_Tx ();

// Testbench ports
localparam CLK_PERIOD = 10; // 100 Hz clk
logic tb_clk, tb_nRst, tb_ready, tb_transmit_ready, tb_blue, tb_tx_ctrl, tb_tx_serial;
logic tb_msg, tb_tx_byte;

// Clock generation block
always begin
    tb_clk = 1'b0; 
    #(CLK_PERIOD / 2.0);
    tb_clk = 1'b1; 
    #(CLK_PERIOD / 2.0); 
end

// Portmap
INT_TOP_message_TX mesgsgs (.tb_clk(tb_clk), .tb_nRst(tb_nRst), .tb_tx_serial(tb_tx_serial), .tb_ready(tb_ready));

initial begin 
    // Signal dump
    $dumpfile("dump.vcd");
    $dumpvars; 

    // Initialize test bench signals
    tb_msg = 8'hA;
    tb_ready = 0;

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



end
endmodule