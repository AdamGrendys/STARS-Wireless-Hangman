/* Module Name: tb_keypad_fsm
 * Description: Test bench for keypad_fsm module
 */

`timescale 1 ms / 100us

module tb_keypad_fsm ();

    // Test bench parameters
    localparam CLK_PERIOD = 10; // 100 Hz clock
    logic tb_checking_outputs;
    integer tb_test_num;
    string tb_test_case;

    // DUT ports
    logic tb_clk, tb_nRst_i, tb_strobe_i;
    logic [7:0] tb_cur_key_i;
    logic tb_ready_o;
    logic tb_game_end_o;
    logic [7:0] tb_data_o;

    // Reset DUT Task
    task reset_dut;
        @(negedge tb_clk);
        tb_nRst_i = 1'b0; // Activate reset
        tb_strobe_i = 1'b0;
        tb_cur_key_i = 8'd0;

        @(negedge tb_clk);
        @(negedge tb_clk);
        tb_nRst_i = 1'b1; // Deactivate reset

        @(posedge tb_clk);
    endtask

    // Task to check current data
    task check_data_o;
    input logic [7:0] exp_data_o;
    begin
        //@(negedge tb_clk);
        tb_checking_outputs = 1'b1;
        if (tb_data_o == exp_data_o)
            $info("Correct Data: %b", exp_data_o);
        else
            $error("Incorrect data. Expected: %b. Actual: %b", exp_data_o, tb_data_o);
       
        #(1);
        tb_checking_outputs = 1'b0;
    end
    endtask

    // Task to check ready signal
    task check_ready_o;
    input logic exp_ready_o;
    begin
        //@(negedge tb_clk);
        tb_checking_outputs = 1'b1;
        if (tb_ready_o == exp_ready_o)
            $info("Correct: %d", exp_ready_o);
        else
            $error("Incorrect. Expected: %d. Actual: %d", exp_ready_o, tb_ready_o);
        #(1);
        tb_checking_outputs = 1'b0;
    end
    endtask

    // Task to check game end signal
    task check_game_end_o;
    input logic exp_game_end_o;
    begin
        //@(negedge tb_clk);
        tb_checking_outputs = 1'b1;
        if (tb_game_end_o == exp_game_end_o)
            $info("Correct: %d", exp_game_end_o);
        else
            $error("Incorrect. Expected: %d. Actual: %d", exp_game_end_o, tb_game_end_o);
        #(1);
        tb_checking_outputs = 1'b0;
    end
    endtask

    // Clock generation block
    always begin
        tb_clk = 1'b0;
        #(CLK_PERIOD / 2.0);
        tb_clk = 1'b1;
        #(CLK_PERIOD / 2.0);
    end

    // DUT Port Map
    keypad_fsm DUT (.clk (tb_clk),
                    .nRst (tb_nRst_i),
                    .strobe (tb_strobe_i),
                    .cur_key (tb_cur_key_i),
                    .ready (tb_ready_o),
                    .game_end (tb_game_end_o),
                    .data (tb_data_o));

    // Main Test Bench Processes
    initial begin
        // Signal dump
        $dumpfile("dump.vcd");
        $dumpvars;

        // Initialize test bench signals
        tb_nRst_i = 1'b1;
        tb_strobe_i = 1'b0;
        tb_cur_key_i = 8'd0;
        tb_checking_outputs = 1'b0;
        tb_test_num = -1;
        tb_test_case = "Initializing";

        // Wait some time before starting first test case
        #(0.1);

        // **************************************
        // Test Case 0: Power-on-Reset of the DUT
        // **************************************
        tb_test_num += 1;
        tb_test_case = "Test Case 0: Power-on-Reset of the DUT";
        $display("\n\n%s", tb_test_case);

        @(negedge tb_clk);
        tb_cur_key_i = {4'b1000, 4'b0100}; // R0 C1 -> 'A'
        repeat (2) @(negedge tb_clk);
        @(posedge tb_clk); // Delayed for 2 clock cycles
        tb_strobe_i = 1'b1;
        
        @(negedge tb_clk);
        tb_nRst_i = 1'b0; // Activate reset
        tb_cur_key_i = 8'd0; // Input values reset
        tb_strobe_i = 1'b0;

        // Wait for a bit before checking for correct functionality
        #(2);
        // All columns are inactive, so no key press is registered
        @(negedge tb_clk);
        check_data_o(8'd0);
        check_ready_o(1'b0);
        check_game_end_o(1'b0);

        // Check that the reset value is maintained during a clock cycle
        @(negedge tb_clk);
        check_data_o(8'd0);
        check_ready_o(1'b0);
        check_game_end_o(1'b0);      

        // Release the reset away from a clock edge
        @(negedge tb_clk);
        tb_nRst_i = 1'b1; // Deactivate reset

        // Check that internal state was correctly kept after reset release
        @(negedge tb_clk);
        check_data_o(8'd0);
        check_ready_o(1'b0);
        check_game_end_o(1'b0);

        // ********************************************************
        // Test Case 1: Toggle through 3-letter set and wrap around
        // ********************************************************
        tb_test_num += 1;
        tb_test_case = "Test Case 1: Toggle through 3-letter set and wrap around";
        $display("\n\n%s", tb_test_case);

        // Letter set 2, state S0
        @(negedge tb_clk);
        tb_cur_key_i = {4'b1000, 4'b0010}; // R0 C2 -> 'D'
        repeat (2) @(negedge tb_clk);
        @(posedge tb_clk); // Delay of 2 clock cycles
        tb_strobe_i = 1'b1;
        #(1);

        //@(negedge tb_clk); // Because strobe is high, letter set
        check_data_o(8'd68);
        check_ready_o(1'b0);
        check_game_end_o(1'b0);
        tb_strobe_i = 1'b0;
        tb_cur_key_i = 8'd0; // Let go of key to stop hold

        // Letter set 2, state S1
        @(negedge tb_clk);
        tb_cur_key_i = {4'b1000, 4'b0010}; // R0 C2 -> 'E'
        repeat (2) @(negedge tb_clk);
        @(posedge tb_clk); // Delay of 2 clock cycles
        tb_strobe_i = 1'b1;

        @(negedge tb_clk);
        check_data_o(8'd69);
        check_ready_o(1'b0);
        check_game_end_o(1'b0);
        tb_strobe_i = 1'b0;
        tb_cur_key_i = 8'd0; // Let go of key to stop hold

        // Letter set 2, state S2
        @(negedge tb_clk);
        tb_cur_key_i = {4'b1000, 4'b0010}; // R0 C2 -> 'F'
        repeat (2) @(negedge tb_clk);
        @(posedge tb_clk); // Delay of 2 clock cycles
        tb_strobe_i = 1'b1;

        @(negedge tb_clk);
        check_data_o(8'd70);
        check_ready_o(1'b0);
        check_game_end_o(1'b0);
        tb_strobe_i = 1'b0;
        tb_cur_key_i = 8'd0; // Let go of key to stop hold

        // Letter set 2, state S0 (wrap around)
        @(negedge tb_clk);
        tb_cur_key_i = {4'b1000, 4'b0010}; // R0 C2 -> 'D'
        repeat (2) @(negedge tb_clk);
        @(posedge tb_clk); // Delay of 2 clock cycles
        tb_strobe_i = 1'b1;

        @(negedge tb_clk);
        check_data_o(8'd68);
        check_ready_o(1'b0);
        check_game_end_o(1'b0);
        tb_strobe_i = 1'b0;
        tb_cur_key_i = 8'd0; // Let go of key to stop hold

        // **********************
        // Test Case 2: Clear key
        // **********************
        tb_test_num += 1;
        tb_test_case = "Test Case 2: Clear key";
        $display("\n\n%s", tb_test_case);

        // ************************************************************
        // Test Case 3: Non-default letter of set, change sets, go back
        // ************************************************************
        tb_test_num += 1;
        tb_test_case = "Test Case 3: Non-default letter of set, change sets, go back";
        $display("\n\n%s", tb_test_case);

        // **********************************************
        // Test Case 4: Invalid key (no impact on letter)
        // **********************************************
        tb_test_num += 1;
        tb_test_case = "Test Case 4: Invalid key (no impact on letter)";
        $display("\n\n%s", tb_test_case);

        // *****************************************
        // Test Case 5: Submit letter (ready signal)
        // *****************************************
        tb_test_num += 1;
        tb_test_case = "Test Case 5: Submit letter (ready signal)";
        $display("\n\n%s", tb_test_case); 

        // Also: Change to INIT right after

        // ********************************************************
        // Test Case 6: Toggle through 4-letter set and wrap around
        // ********************************************************
        tb_test_num += 1;
        tb_test_case = "Test Case 6: Toggle through 4-letter set and wrap around";
        $display("\n\n%s", tb_test_case); 

        // *****************************************************
        // Test Case 7: Game end key (data clear, game end high)
        // *****************************************************
        tb_test_num += 1;
        tb_test_case = "Test Case 5: Game end key (data clear, game end high)";
        $display("\n\n%s", tb_test_case); 

        // TODO
    $finish;
    end
endmodule