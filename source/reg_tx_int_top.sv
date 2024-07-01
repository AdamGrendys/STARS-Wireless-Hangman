module reg_tx_int_top (
    input logic clk, nRst, ready,
    output logic tx_serial,
    output logic transmit_ready, blue, tx_ctrl,
    output logic [7:0] tx_byte,
    input logic [7:0] msg


);

// Testbench ports
localparam CLK_PERIOD = 10; // 100 Hz clk
// logic transmit_readymit_ready, blue, tx_ctrl;
// logic [7:0] msg, tx_byte;

// Portmap
Message_Reg message_reg (.clk(clk), .nRst(nRst), .ready(ready), .transmit_ready(transmit_ready), .data(msg), .blue(blue), .tx_ctrl(tx_ctrl), .tx_byte(tx_byte));
UART_Tx uart_transmitter (.clk(clk), .nRst(nRst), .tx_ctrl(tx_ctrl), .tx_byte(tx_byte), .transmit_ready(transmit_ready), .tx_serial(tx_serial));

endmodule

