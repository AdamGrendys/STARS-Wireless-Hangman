/* UART Reciever + Buffer Integration Test
Descriuption: x
*/

`timescale 1ms / 100 us

module INT_GameRxTx ();

// Testbench ports
localparam CLK_PERIOD = 10; // 100 Hz clk
logic tb_clk, tb_nRst, tb_rec_ready, tb_ready; //Input
logic tb_toggle_state, tb_gameEnd_host; //Input
logic [39:0] tb_setWord; //Input
logic [7:0] tb_msg;//Input

logic tb_err_LED, tb_blue, tb_red, tb_green; //Output
logic [2:0] tb_incorrect, tb_correct; //Output
logic [4:0] tb_indexCorrect; //Output
logic [7:0] tb_letter; //Output
logic tb_red_busy, tb_mistake; //Output



// Clock generation block
always begin
    tb_clk = 1'b0; 
    #(CLK_PERIOD / 2.0);
    tb_clk = 1'b1; 
    #(CLK_PERIOD / 2.0); 
end

// Portmap
INT_TOP_GameReg game0 (.clk(tb_clk), .nRst(tb_nRst), .msg(tb_msg), .ready(tb_ready), .rec_ready(tb_rec_ready), .err_LED(tb_err_LED), .blue(tb_blue), .setWord(tb_setWord), .toggle_state(tb_toggle_state), .letter(tb_letter), .red(tb_red), .green(tb_green),
.mistake(tb_mistake), .red_busy(tb_red_busy), .incorrect(tb_incorrect), .correct(tb_correct), .indexCorrect(tb_indexCorrect), .gameEnd_host(tb_gameEnd_host));


initial begin 
    // Signal dump
    $dumpfile("dump.vcd");
    $dumpvars; 

    // Initialize test bench signals
    tb_ready = 0;
    tb_setWord = 40'b0100110101001111010011110101001001000101;
    tb_rec_ready = 1;
    tb_toggle_state = 0;
    tb_gameEnd_host = 0;

    // Wait some time before starting first test case
    #(0.1);

    // ***********************************
    // Test Case 0: Power-on-Reset 
    // ***********************************
    #(CLK_PERIOD * 2);
    @(negedge tb_clk);
    tb_nRst = 1'b0; 
    @(negedge tb_clk);
    @(negedge tb_clk);
    tb_nRst = 1'b1;
    @(posedge tb_clk);
    #(CLK_PERIOD * 2);

    // ***********************************
    // Test Case 1: Player win and double correct guess
    // ***********************************
    tb_toggle_state = 1;
    #(CLK_PERIOD * 50);
    tb_msg = 8'b01001111; //GUESS O
    tb_toggle_state = 0;
    #(CLK_PERIOD * 10);
    tb_ready = 1;
    #(CLK_PERIOD * 10);
    tb_ready = 0;
    #(CLK_PERIOD * 15000);

    tb_msg = 8'b01010000; //GUESS P
    tb_toggle_state = 0;
    #(CLK_PERIOD * 10);
    tb_ready = 1;
    #(CLK_PERIOD * 10);
    tb_ready = 0;
    #(CLK_PERIOD * 15000);

    tb_msg = 8'b01001101; //GUESS M
    tb_toggle_state = 0;
    #(CLK_PERIOD * 10);
    tb_ready = 1;
    #(CLK_PERIOD * 10);
    tb_ready = 0;
    #(CLK_PERIOD * 15000);

    tb_msg = 8'b01001101; //GUESS M AGAIN
    tb_toggle_state = 0;
    #(CLK_PERIOD * 10);
    tb_ready = 1;
    #(CLK_PERIOD * 10);
    tb_ready = 0;
    #(CLK_PERIOD * 15000);

    tb_msg = 8'b01010010; //GUESS R
    tb_toggle_state = 0;
    #(CLK_PERIOD * 10);
    tb_ready = 1;
    #(CLK_PERIOD * 10);
    tb_ready = 0;
    #(CLK_PERIOD * 15000);

    tb_msg = 8'b01000101; //GUESS E
    tb_toggle_state = 0;
    #(CLK_PERIOD * 10);
    tb_ready = 1;
    #(CLK_PERIOD * 10);
    tb_ready = 0;
    #(CLK_PERIOD * 15000);
    tb_gameEnd_host = 1;
    #CLK_PERIOD
    tb_gameEnd_host = 0;

    // ***********************************
    // Test Case 2: Player loss
    // ***********************************

    #(CLK_PERIOD * 100);
    tb_setWord = 40'b0101100101010101010011010100110101011001;

    tb_toggle_state = 1;
    #(CLK_PERIOD * 50);
    tb_msg = 8'b01001001; //GUESS I
    tb_toggle_state = 0;
    #(CLK_PERIOD * 10);
    tb_ready = 1;
    #(CLK_PERIOD * 10);
    tb_ready = 0;
    #(CLK_PERIOD * 15000);

    tb_msg = 8'b01001100; //GUESS L
    tb_toggle_state = 0;
    #(CLK_PERIOD * 10);
    tb_ready = 1;
    #(CLK_PERIOD * 10);
    tb_ready = 0;
    #(CLK_PERIOD * 15000);

    tb_msg = 8'b01001011; //GUESS K
    tb_toggle_state = 0;
    #(CLK_PERIOD * 10);
    tb_ready = 1;
    #(CLK_PERIOD * 10);
    tb_ready = 0;
    #(CLK_PERIOD * 15000);

    tb_msg = 8'b01001110; //GUESS N
    tb_toggle_state = 0;
    #(CLK_PERIOD * 10);
    tb_ready = 1;
    #(CLK_PERIOD * 10);
    tb_ready = 0;
    #(CLK_PERIOD * 15000);

    tb_msg = 8'b01001010; //GUESS J
    tb_toggle_state = 0;
    #(CLK_PERIOD * 10);
    tb_ready = 1;
    #(CLK_PERIOD * 10);
    tb_ready = 0;
    #(CLK_PERIOD * 15000);

    tb_msg = 8'b01000110; //GUESS F
    tb_toggle_state = 0;
    #(CLK_PERIOD * 10);
    tb_ready = 1;
    #(CLK_PERIOD * 10);
    tb_ready = 0;
    #(CLK_PERIOD * 15000);
    tb_gameEnd_host = 1;
    #CLK_PERIOD
    tb_gameEnd_host = 0;


    // ***********************************
    // Test Case 2: Mid-reset
    // ***********************************

    #(CLK_PERIOD * 100);
    tb_setWord = 40'b0101100101010101010011010100110101011001;

    tb_toggle_state = 1;
    #(CLK_PERIOD * 50);
    tb_msg = 8'b01001001; //GUESS I
    tb_toggle_state = 0;
    #(CLK_PERIOD * 10);
    tb_ready = 1;
    #(CLK_PERIOD * 10);
    tb_ready = 0;
    #(CLK_PERIOD * 15000);

    tb_msg = 8'b01001100; //GUESS L
    tb_toggle_state = 0;
    #(CLK_PERIOD * 10);
    tb_ready = 1;
    #(CLK_PERIOD * 10);
    tb_ready = 0;
    #(CLK_PERIOD * 15000);

    tb_nRst = 0;
    #CLK_PERIOD;
    tb_nRst = 1;


    $finish;

end
endmodule
