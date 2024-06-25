/* UART Reciever + Buffer Integration Test
Descriuption: x
*/

`timescale 1ms / 100 us

module INT_Buff_UART_Rx ();

// Testbench ports
localparam CLK_PERIOD = 10; // 100 Hz clk
logic tb_clk, tb_nRst, tb_rx_serial, tb_rec_ready; //Input of UART_Rx
logic tb_error_led; //output of UART_Rx, rx_ready is also input of buffer
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
buffRX bufferRecieve (.clk(tb_clk), .nRst(tb_nRst), .rx_serial(tb_rx_serial), .rec_ready(tb_rec_ready), .error_led(tb_error_led), .guess(tb_guess));

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
    tb_rx_serial = 0;
    tb_rec_ready = 0;
    tb_error_led = 0;
    temphold = 8'hA;

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
    #CLK_PERIOD;
    for(integer i = 0; i < 8; i = i + 1) begin
        #(CLK_PERIOD * 1250);
        tb_rx_serial = temphold[i];
    end
    #CLK_PERIOD
    guess_check(temphold, "A");

    // ***********************************
    // Test Case 2: Error with recieving message
    // ***********************************


    $finish;

end
endmodule
