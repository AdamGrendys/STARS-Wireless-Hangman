/* Main File
Descriuption: x
*/

module main (
    input logic clk, nRst, role_switch,
    input logic [3:0] input_row_player, input_row_host,
    output logic red, green, blue, error, msg_sent,
    output logic [127:0] play_row1, play_row2, host_row1, host_row2
);
// Local Variable Declarations for both player and host 
logic new_clk, useless; // Clock output signal from clock divider
// Local Variable Declarations - Player 
logic ready, transmit_ready, tx_ctrl, tx_serial, toggle_state, strobe_player, gameEnd_player;
logic [7:0] msg, tx_byte, cur_key_player;
logic [3:0] scan_col_player;
// Local Variable Declarations - Host 
logic strobe_host, gameEnd_host, key_ready, rec_ready_host, toggle_state_host, mistake, rx_ready, red_busy;
logic [3:0] scan_col_host;
logic [7:0] cur_key_host, setLetter, guess, letter, rx_byte;
logic [39:0] temp_word; 
logic [2:0] incorrect, correct;
logic [4:0] indexCorrect;
// LCD Outputs
logic [7:0] lcd_data1, lcd_data2;
logic lcd_en1, lcd_en2, lcd_rw1, lcd_rw2, lcd_rs1, lcd_rs2;

// ***********
// Global 
// ***********

clock_divider clock_div (.clk (clk), .nRst (nRst), .max (17'd100000), .at_max (new_clk));

// ***********
// Player Side
// ***********

keypad_controller keypadplayer (.mode(role_switch), .clk(clk), .nRst(nRst), .read_row(input_row_player), .cur_key(cur_key_player), .strobe(strobe_player), .scan_col(scan_col_player), .enable(new_clk));
keypad_fsm keypadFSMPlayer (.clk(clk), .nRst(nRst), .strobe(strobe_player), .cur_key(cur_key_player), .ready(ready), .data(msg), .game_end(gameEnd_player), .toggle_state(useless));

disp_fsm dispFSM (.clk(clk), .nRst(nRst), .ready(ready), .msg(msg), .row1(play_row1), .row2(play_row2), .gameEnd(gameEnd_player));

msg_reg message_reg (.clk(clk), .nRst(nRst), .ready(ready), .transmit_ready(transmit_ready), .data(msg), .blue(msg_sent), .tx_ctrl(tx_ctrl), .tx_byte(tx_byte));

uart_tx uart_transmitter (.clk(clk), .nRst(nRst), .tx_ctrl(tx_ctrl), .tx_byte(tx_byte), .transmit_ready(transmit_ready), .tx_serial(tx_serial));

// lcd_controller lcdPlayer (.clk(clk), .rst(nRst), .row_1(play_row1), .row_2(play_row2), .lcd_en(lcd_en1), .lcd_rw(lcd_rw1), .lcd_rs(lcd_rs1), .lcd_data(lcd_data1));


// *********
// Host Side
// *********

keypad_controller keypadHostt (.mode(~role_switch), .clk(clk), .nRst(nRst), .read_row(input_row_host), .cur_key(cur_key_host), .strobe(strobe_host), .scan_col(scan_col_host), .enable(new_clk));
keypad_fsm keypadFSMHost (.clk(clk), .nRst(nRst), .strobe(strobe_host), .cur_key(cur_key_host), .ready(key_ready), .data(setLetter), .game_end(gameEnd_host), .toggle_state(toggle_state_host));

host_msg_reg host_message_reg (.clk(clk), .nRst(nRst), .key_ready(key_ready), .toggle_state(toggle_state_host), .setLetter(setLetter), .rec_ready(rec_ready_host), .temp_word(temp_word), .gameEnd_host(gameEnd_host));

uart_rx uart_receiver (.clk(clk), .nRst(nRst), .rx_serial(tx_serial), .rec_ready(rec_ready_host), .rx_ready(rx_ready), .rx_byte(rx_byte), 
.error_led(error));

buffer buffer (.clk(clk), .nRst(nRst), .Rx_byte(rx_byte), .rx_ready(rx_ready), .game_rdy(blue), .guess(guess));

game_logic gamelogic (.clk(clk), .nRst(nRst), .guess(guess), .setWord(temp_word), .toggle_state(toggle_state_host), .letter(letter), .red(red), .green(green),
.mistake(mistake), .red_busy(red_busy), .game_rdy(blue), .incorrect(incorrect), .correct(correct), .indexCorrect(indexCorrect), .gameEnd(gameEnd_host));

host_disp hostdisp (.clk(clk), .nRst(nRst), .indexCorrect(indexCorrect), .letter(letter), .incorrect(incorrect), .correct(correct), .temp_word(temp_word), .setLetter(setLetter), .toggle_state(toggle_state_host), .gameEnd_host(gameEnd_host), .mistake(mistake), .top(host_row1), .bottom(host_row2));

// lcd_controller lcdHost (.clk(clk), .rst(nRst), .row_1(host_row1), .row_2(host_row2), .lcd_en(lcd_en2), .lcd_rw(lcd_rw2), .lcd_rs(lcd_rs2), .lcd_data(lcd_data2));

endmodule