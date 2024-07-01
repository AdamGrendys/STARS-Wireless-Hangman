/* UART Reciever + Buffer Integration Test
Descriuption: x
*/

`timescale 1ms / 100 us

module buffer_rx_int ();

// Testbench ports
localparam CLK_PERIOD = 10; // 100 Hz clk
logic tb_clk, tb_nRst, tb_rx_serial, tb_rec_ready, tb_game_rdy; //Input of UART_Rx
logic tb_error_led; //output of UART_Rx
logic [7:0] tb_guess; //output of buffer
logic [7:0] temphold; //value to feed into reciever

// Clock generation block
always begin
    tb_clk = 1'b0; 
    #(CLK_PERIOD / 2.0);
    tb_clk = 1'b1; 
    #(CLK_PERIOD / 2.0); 
end

// Portmap
INT_TOP_Buff_Rx bufferRecieve (.clk(tb_clk), .nRst(tb_nRst), .rx_serial(tb_rx_serial), .rec_ready(tb_rec_ready), .err_LED(tb_error_led), .guess(tb_guess), .game_rdy(tb_game_rdy));

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
    tb_rx_serial = 1;
    tb_rec_ready = 0;
    temphold = 8'b11011011;
    tb_game_rdy = 1;

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
    // Test Case 1: Message recieved 
    // ***********************************

    tb_rec_ready = 1;
    tb_rx_serial = 0;
    #CLK_PERIOD;
    for(integer i = 0; i < 8; i = i + 1) begin
        #(CLK_PERIOD * 1250);
        tb_rx_serial = temphold[i];
    end
   
    #(CLK_PERIOD * 1250);
    tb_rx_serial = 0;
    
    #(CLK_PERIOD * 1250);
    tb_rx_serial = 1;

    #CLK_PERIOD
    guess_check(temphold, "A");
    
    #(CLK_PERIOD * 15000);
    
    // ***********************************
    // Test Case 2: Error with recieving message
    // ***********************************
    tb_rec_ready = 0;
    #CLK_PERIOD;
    
    for(integer i = 0; i < 8; i = i + 1) begin
        #(CLK_PERIOD * 1250);
        tb_rx_serial = temphold[i];
    end
    #CLK_PERIOD
    guess_check(temphold, "A");
    #(CLK_PERIOD * 15000);




    $finish;

end
endmodule
