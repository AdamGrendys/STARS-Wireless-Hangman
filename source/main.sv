/* Main File
Descriuption: x
*/

module main (
    input logic clk, nRst,
    output logic red, green, blue, error,
    output logic [127:0] play_row1, play_row2, host_row1, host_row2
);
// Local Variable Declarations
logic ready, transmit_ready, tx_ctrl, tx_serial, rec_ready, rx_ready, toggle_state, mistake, red_busy, strobe_player, strobe_host, gameEnd_player, gameEnd_host;
logic [7:0] msg, tx_byte, rx_byte, guess, letter, cur_key_player, cur_key_host;
logic [39:0] setWord;
logic [2:0] incorrect, correct;
logic [4:0] indexCorrect, input_row_player, input_row_host, scan_col_player, scan_col_host;

// LCD Outputs
logic [7:0] lcd_data1, lcd_data2;
logic lcd_en1, lcd_en2, lcd_rw1, lcd_rw2, lcd_rs1, lcd_rs2;


// ***********
// Player Side
// ***********

keypad_controller keypadplayer (.clk(clk), .nRst(nRst), .read_row(input_row_player), .cur_key(cur_key_player), .strobe(strobe_player), .scan_col(scan_col_player));
keypad_fsm keypadFSMPlayer (.clk(clk), .nRst(nRst), .strobe(strobe_player), .cur_key(cur_key_player), .ready(ready), .data(msg), .gameEnd(gameEnd_player));

Display_FSM dispFSM (.clk(clk), .nRst(nRst), .ready(ready), .msg(msg), .row1(play_row1), .row2(play_row2));

Message_Reg message_reg (.clk(clk), .nRst(nRst), .ready(ready), .transmit_ready(transmit_ready), .data(msg), .blue(blue), .tx_ctrl(tx_ctrl), .tx_byte(tx_byte));

UART_Tx uart_transmitter (.clk(clk), .nRst(nRst), .tx_ctrl(tx_ctrl), .tx_byte(tx_byte), .transmit_ready(transmit_ready), .tx_serial(tx_serial));

lcd_controller lcdPlayer (.clk(clk), .rst(nRst), .row_1(play_row1), .row_2(play_row2), .lcd_en(lcd_en1), .lcd_rw(lcd_rw1), .lcd_rs(lcd_rs1), .lcd_data(lcd_data1));


// *********
// Host Side
// *********

keypad_controller keypadHostt (.clk(clk), .nRst(nRst), .read_row(input_row_host), .cur_key(cur_key_host), .strobe(strobe_host), .scan_col(scan_col_host));
keypad_fsm keypadFSMHost (.clk(clk), .nRst(nRst), .strobe(strobe_host), .cur_key(cur_key_host), .ready(ready), .data(msg), .gameEnd(gameEnd_host));

UART_Rx uart_receiver (.clk(clk), .nRst(nRst), .rx_serial(tx_serial), .rec_ready(rec_ready), .rx_ready(rx_ready), .rx_byte(rx_byte), 
.error_led(error));

Buffer buffer (.clk(clk), .nRst(nRst), .Rx_byte(rx_byte), .rx_ready(rx_ready), .game_rdy(blue), .guess(guess));

Game_Logic gamelogic (.clk(clk), .nRst(nRst), .guess(guess), .setWord(setWord), .toggle_state(toggle_state), .letter(letter), .red(red), .green(green),
.mistake(mistake), .red_busy(red_busy), .game_rdy(blue), .incorrect(incorrect), .correct(correct), .indexCorrect(indexCorrect), .gameEnd(gameEnd_host));

HostDisplay hostdisp (.clk(clk), .nRst(nRst), .indexCorrect(indexCorrect), .letter(letter), .incorrect(incorrect), .correct(correct), .word(setWord), 
.mistake(mistake), .top(host_row1), .bottom(host_row2));

lcd_controller lcdHost (.clk(clk), .rst(nRst), .row_1(host_row1), .row_2(host_row2), .lcd_en(lcd_en2), .lcd_rw(lcd_rw2), .lcd_rs(lcd_rs2), .lcd_data(lcd_data2));

endmodule