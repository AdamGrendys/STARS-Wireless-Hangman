module INT_TOP_message_TX (
    input logic tb_clk, tb_nRst, tb_ready,
    output logic tb_tx_serial,
    output logic tb_transmit_ready, tb_blue, tb_tx_ctrl,
    output logic [7:0] tb_msg, tb_tx_byte


);

// Testbench ports
localparam CLK_PERIOD = 10; // 100 Hz clk
// logic tb_transmit_ready, tb_blue, tb_tx_ctrl;
// logic [7:0] tb_msg, tb_tx_byte;

// Portmap
Message_Reg message_reg (.clk(tb_clk), .nRst(tb_nRst), .ready(tb_ready), .transmit_ready(tb_transmit_ready), .data(tb_msg), .blue(tb_blue), .tx_ctrl(tb_tx_ctrl), .tx_byte(tb_tx_byte));
UART_Tx uart_transmitter (.clk(tb_clk), .nRst(tb_nRst), .tx_ctrl(tb_tx_ctrl), .tx_byte(tb_tx_byte), .transmit_ready(tb_transmit_ready), .tx_serial(tb_tx_serial));

endmodule
