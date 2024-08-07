/* UART TX + Rx Integration Module
Descriuption: x
*/

module reg_host_int_top (
    input logic clk, nRst, ready, rec_ready, //Input of UART_Rx
    input logic toggle_state, gameEnd_host,
    input logic [7:0] msg,
    input logic [39:0] setWord,  
    output logic err_LED, blue, red, green, //output of UART_Rx 
    output logic [127:0] host_row1, host_row2
);
logic rx_serial, game_rdy, transmit_ready, tx_ctrl, mistake, red_busy;
logic [7:0] tx_byte;
logic [7:0] guess, letter; //output of buffer
logic [2:0] incorrect, correct;
logic [4:0] indexCorrect;

reg_tx_int_top transmit( .clk(clk), .nRst(nRst), .ready(ready), .tx_serial(rx_serial), .transmit_ready(transmit_ready), .blue(blue), .tx_ctrl(tx_ctrl), .tx_byte(tx_byte), .msg(msg));
buffer_rx_int_top receive(.clk(clk), .nRst(nRst), .rx_serial(rx_serial), .rec_ready(rec_ready), .game_rdy(game_rdy), .err_LED(err_LED), .guess(guess));
game_logic gamelogic (.clk(clk), .nRst(nRst), .guess(guess), .setWord(setWord), .toggle_state(toggle_state), .letter(letter), .red(red), .green(green),
.mistake(mistake), .red_busy(red_busy), .game_rdy(game_rdy), .incorrect(incorrect), .correct(correct), .indexCorrect(indexCorrect), .gameEnd(gameEnd_host));

host_disp hostdisp (.clk(clk), .nRst(nRst), .indexCorrect(indexCorrect), .letter(letter), .incorrect(incorrect), .correct(correct), .word(setWord), 
.mistake(mistake), .top(host_row1), .bottom(host_row2), .gameEnd_host(gameEnd_host));

endmodule