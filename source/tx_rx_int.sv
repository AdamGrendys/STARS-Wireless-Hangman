/* UART Reciever + Buffer Integration Test
Descriuption: x
*/

`timescale 1ms / 100 us

module INT_TxRx ();

// Testbench ports
localparam CLK_PERIOD = 10; // 100 Hz clk
logic tb_clk, tb_nRst, tb_ready, tb_rec_ready, tb_game_rdy; //Input of UART_Rx
logic tb_error_led, tb_blue; //output of UART_Rx
logic [7:0] tb_guess, tb_msg; //output of buffer


// Clock generation block
always begin
    tb_clk = 1'b0; 
    #(CLK_PERIOD / 2.0);
    tb_clk = 1'b1; 
    #(CLK_PERIOD / 2.0); 
end

// Portmap
INT_TOP_TxRx TR (.clk(tb_clk), .nRst(tb_nRst), .ready(tb_ready), .rec_ready(tb_rec_ready), .err_LED(tb_error_led), .guess(tb_guess), .game_rdy(tb_game_rdy), .msg(tb_msg), .blue(tb_blue));

task guess_check;
input logic[7:0] expected_guess;
input string string_guess;
begin
    @(negedge tb_clk);
    if(tb_guess == expected_guess)
        $info("Guess matches buffer output: %s.", string_guess);
    else
        $error("Guess does not match buffer output: %s. Actual: %s.", string_guess, tb_guess);
end
endtask


initial begin 
    // Signal dump
    $dumpfile("dump.vcd");
    $dumpvars; 

    // Initialize test bench signals
    tb_nRst = 1;
    tb_rec_ready = 1;
    tb_game_rdy = 1;

    // Wait some time before starting first test case
    #(0.1);

    // ***********************************
    // Test Case 0: Power-on-Reset 
    // ***********************************
    #(CLK_PERIOD * 100);
    @(negedge tb_clk);
    tb_nRst = 1'b0; 
    @(negedge tb_clk);
    @(negedge tb_clk);
    tb_nRst = 1'b1;
    @(posedge tb_clk);
    #(CLK_PERIOD * 100);

    tb_ready = 0;
    tb_msg = 8'b10101001;
    #(CLK_PERIOD * 1000);

    tb_ready = 1;
    #(CLK_PERIOD * 500);
    tb_ready = 0;
    #(CLK_PERIOD * 20000);

    tb_msg = 8'b10101010;
    #(CLK_PERIOD * 500);
    tb_ready = 1;
    #(CLK_PERIOD * 50);
    tb_ready = 0;

    #(CLK_PERIOD * 20000);

    $finish;
    
end
endmodule