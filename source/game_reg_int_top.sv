/* UART TX + Rx Integration Module
Descriuption: x
*/

module game_reg_int_top (
    input logic clk, nRst, ready, rec_ready, //Input of UART_Rx
    input logic toggle_state, gameEnd_host,
    output logic err_LED, blue, red, green, //output of UART_Rx 
    input logic [39:0] setWord,
    input logic [7:0] msg, 
    output logic [2:0] incorrect, correct,
    output logic [4:0] indexCorrect,
    output logic [7:0] letter,
    output logic red_busy, mistake
);
logic rx_serial, game_rdy, transmit_ready, tx_ctrl;
logic [7:0] tx_byte;
logic [7:0] guess; //output of buffer

INT_TOP_Reg_Tx transmit( .clk(clk), .nRst(nRst), .ready(ready), .tx_serial(rx_serial), .transmit_ready(transmit_ready), .blue(blue), .tx_ctrl(tx_ctrl), .tx_byte(tx_byte), .msg(msg));
INT_TOP_Buff_Rx receive(.clk(clk), .nRst(nRst), .rx_serial(rx_serial), .rec_ready(rec_ready), .game_rdy(game_rdy), .err_LED(err_LED), .guess(guess));
Game_Logic gamelogic (.clk(clk), .nRst(nRst), .guess(guess), .setWord(setWord), .toggle_state(toggle_state), .letter(letter), .red(red), .green(green),
.mistake(mistake), .red_busy(red_busy), .game_rdy(game_rdy), .incorrect(incorrect), .correct(correct), .indexCorrect(indexCorrect), .gameEnd(gameEnd_host));

endmodule