/* UART Reciever + Buffer Integration Module
Descriuption: x
*/

module INT_TOP_Buff_Rx(
    input logic clk, nRst, rx_serial, rec_ready, game_rdy, //Input of UART_Rx
    output logic err_LED, //output of UART_Rx 
    output logic [7:0] guess //output of buffer
);
logic rx_ready; //output of UART_Rx, rx_ready is also input of buffer
logic [7:0] rx_byte; //output of UART_Rx and input of buffer

Buffer buff (.clk(clk), .nRst(nRst), .Rx_byte(rx_byte), .game_rdy(game_rdy), .rx_ready(rx_ready), .guess(guess));
UART_Rx reciever(.clk(clk), .nRst(nRst), .rx_serial(rx_serial), .rec_ready(rec_ready), .error_led(err_LED), .rx_ready(rx_ready), .rx_byte(rx_byte));

endmodule