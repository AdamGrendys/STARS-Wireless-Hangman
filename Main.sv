/* Main File
Descriuption: x
*/

module main (
    input logic clk, nRst, 
    input logic [3:0] play_row, play_col, host_row, host_col,
    output logic [127:0] play_row1, play_row2, host_row1, host_row2
);
// Local Variable Declarations



// Player Side
keypad_controller_player kpd1 (.clk(clk), .nRst(nRst), .row(play_row), .col(play_col), .ready(ready), .msg(msg));

display_fsm dispFSM (.clk(clk), .nRst(nRst), .ready(ready), .msg(msg), .row1(play_row1), .row2(play_row2));

msg_reg message_reg (.clk(clk), .nRst(nRst), .ready(ready), .transmit_ready(transmit_ready), .data(msg), .blue(blue), .tx_ctrl(tx_ctrl), .tx_byte(tx_byte));



// Host Side


endmodule