/* UART TX + Rx Integration Module
Descriuption: x
*/

module INT_TOP_TxRx(
    input logic clk, nRst, ready, rec_ready, game_rdy, //Input of UART_Rx
    output logic err_LED, blue, //output of UART_Rx 
    output logic [7:0] guess, //output of buffer
    input logic [7:0] msg
);
logic rx_serial, transmit_ready, tx_ctrl;
logic [7:0] tx_byte;


INT_TOP_Reg_Tx transmit( .clk(clk), .nRst(nRst), .ready(ready), .tx_serial(rx_serial), .transmit_ready(transmit_ready), .blue(blue), .tx_ctrl(tx_ctrl), .tx_byte(tx_byte), .msg(msg));
INT_TOP_Buff_Rx receive(.clk(clk), .nRst(nRst), .rx_serial(rx_serial), .rec_ready(rec_ready), .game_rdy(game_rdy), .err_LED(err_LED), .guess(guess));

endmodule