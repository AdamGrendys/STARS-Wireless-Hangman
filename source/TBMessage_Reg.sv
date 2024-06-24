/* Message Register File
Descriuption: x
*/

`timescale 1ms / 100 us

typedef enum logic [1:0] {
IDLE = 2'b00, WAIT = 2'b01, TRANSMIT = 2'b11
} curr_state;

module tb_msg_reg ();

// Testbench ports
localparam CLK_PERIOD = 10; // 100 Hz clk
logic tb_clk, tb_nRst, tb_ready, tb_transmit_ready,
logic [7:0] tb_data,
logic tb_blue, tb_tx_ctrl,
logic [7:0] tb_tx_byte
logic [7:0] tb_msg, tb_msg_rdy;
curr_state state, next_state;

// Clock generation block
always begin
    tb_clk = 1'b0; 
    #(CLK_PERIOD / 2.0);
    tb_clk = 1'b1; 
    #(CLK_PERIOD / 2.0); 
end

// Portmap 
msg_reg messsagetest(.clk(tb_clk), .nRst(tb_nRst), .ready(tb_ready), .transmit_ready(tb_transmit_ready), .data(tb_data), .blue(tb_blue), .tx_ctrl(tb_tx_ctrl), .tx_byte(tb_tx_byte));

initial begin 
    // Signal dump
    $dumpfile("dump.vcd");
    $dumpvars; 

    // Initialize test bench signals
    tb_nRst = 1'b1;
    tb_data = 8'd5;
    tb_ready = 0;
    tb_transmit_ready = 0;

    // Wait some time before starting first test case
    #(0.1);

end



endmodule