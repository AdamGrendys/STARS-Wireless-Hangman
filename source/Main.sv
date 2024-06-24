/* Main File
Descriuption: x
*/

module main (
    input logic clk, nRst, 
    output logic [127:0] play_row1, play_row2, host_row1, host_row2
);
// Local Variable Declarations



// Player Side
// kpeypad here

display_fsm dispFSM (.clk(clk), .nRst(nRst), .ready(ready), .msg(msg), .row1(play_row1), .row2(play_row2));

msg_reg message_reg (.clk(clk), .nRst(nRst), .ready(ready), .transmit_ready(transmit_ready), .data(msg), .blue(blue), .tx_ctrl(tx_ctrl), .tx_byte(tx_byte));

uart_tx uart_transmitter #(.Clkperbaud(1250))(.clk(clk), .nRst(nRst), .tx_ctrl(tx_ctrl), .tx_byte(tx_byte), .transmit_ready(transmit_ready), .tx_serial(tx_serial));

// Host Side
// host side keypad here

uart_rx uart_receiver #(.Clkperbaud(1250))(.clk(clk), .nRst(nRst), .rx_serial(tx_serial), .rec_ready(rec_ready), .rx_ready(rx_ready), .rx_byte(rx_byte), error_led1(error1), .error_led2(error2));

buffer buffer (.clk(clk), .nRst(nRst), .rx_byte(rx_byte), .rx_ready(rx_ready), .game_rdy(game_rdy), .))

endmodule