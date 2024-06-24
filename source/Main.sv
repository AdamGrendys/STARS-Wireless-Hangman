/* Main File
Descriuption: x
*/

module main (
    input logic clk, nRst, 
    output logic [127:0] play_row1, play_row2, host_row1, host_row2
);
// Local Variable Declarations
logic ready, transmit_ready, tx_ctrl, tx_serial, rec_ready, rx_ready, game_rdy, toggle_state, mistake, red_busy;
logic [7:0] msg, tx_byte, rx_byte, guess, letter;
logic [39:0] setWord;
logic [2:0] incorrect, correct;
logic [4:0] indexCorrect;


// ***********
// Player Side
// ***********

    // kpeypad here

display_fsm dispFSM (.clk(clk), .nRst(nRst), .ready(ready), .msg(msg), .row1(play_row1), .row2(play_row2));

msg_reg message_reg (.clk(clk), .nRst(nRst), .ready(ready), .transmit_ready(transmit_ready), .data(msg), .blue(blue), .tx_ctrl(tx_ctrl), .tx_byte(tx_byte));

uart_tx uart_transmitter (.clk(clk), .nRst(nRst), .tx_ctrl(tx_ctrl), .tx_byte(tx_byte), .transmit_ready(transmit_ready), .tx_serial(tx_serial));

    // lcd controller here

// *********
// Host Side
// *********

    // host side keypad here

uart_rx uart_receiver (.clk(clk), .nRst(nRst), .rx_serial(tx_serial), .rec_ready(rec_ready), .rx_ready(rx_ready), .rx_byte(rx_byte), 
.error_led1(error1), .error_led2(error2));

buffer buffer (.clk(clk), .nRst(nRst), .rx_byte(rx_byte), .rx_ready(rx_ready), .game_rdy(game_rdy), .guess(guess));

Game_logic gamelogic (.clk(clk), .nRst(nRst), .guess(guess), .setWord(setWord), .toggle_state(toggle_state), .letter(letter), .red(red), .green(green), .blue(blue), 
.mistake(mistake), .red_busy(red_busy), .game_rdy(game_rdy), .incorrect(incorrect), .correct(correct), .indexCorrect(indexCorrect));

HostDisplay hostdisp (.clk(clk), .nRst(nRst), .indexCorrect(indexCorrect), .letter(letter), .numMistake(incorrect), .correct(correct), .word(setWord), 
.mistake(mistake), .top(host_row1), .bottom(host_row2));

    // lcd controller here


endmodule