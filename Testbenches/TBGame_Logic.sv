/* Game Logic File
Descriuption: Controls the states of the game where the host can confirm the word.
Then the next state compares the user input with the different letters in the word.
Finally, once the user either guesses the word, or gets 6 wrong questions, the game
ends. 
*/

module TBGame_Logic ();

typedef enum logic [2:0] { 
    SET = 0, L0 = 1, 
    L1 = 2, L2 = 3, 
    L3 = 4, L4 = 5, 
    STOP = 6
} state_t;

//Testbench parameters
localparam CLK_PERIOD = 10; //100 hz clk
logic tb_checking_outputs;
integer tb_test_num;
string tb_test_case;

//DUT ports
logic tb_clk, tb_nRst;
logic [7:0] tb_guess;
logic [39:0] tb_setWord;
logic tb_toggle_state;
logic [7:0] tb_letter;
logic tb_red, tb_green, tb_mistake, tb_red_busy, tb_game_rdy;
logic [2:0] tb_numMistake, tb_correct;

//Reset DUT Task
task reset_dut;
    @(negedge tb_clk);
    tb_nRst = 1'b0;
    @(negedge tb_clk);
    @(negedge tb_clk);
    tb_nRst = 1'b1;
    @(posedge tb_clk);
endtask

//task that presses the button once
task single_button_press;
begin
    @(negedge tb_clk);
    tb_toggle_state = 1'b1;
    @(negedge tb_clk);
    tb_toggle_state = 1'b0;
    @(posedge tb_clk);
end
endtask

//task to check mistake output
task check_mistake;
input logic[2:0] expected_mistakes;
input string string_mistakes;
begin
    @(negedge tb_clk);
    tb_checking_outputs = 1'b1;
    if(tb_numMistake == expected_mistakes)
        $info("Correct Mistakes: %s.", string_mistakes);
    else
        $error("Incorrect Mistakes. Expected: %s. Actual: %s.", string_mistakes, tb_numMistake);
end
endtask

//task to check correct output
task check_correct;
input logic[2:0] expected_correct;
input string string_correct;
begin
    @(negedge tb_clk);
    tb_checking_outputs = 1'b1;
    if(tb_correct == expected_correct)
        $info("Correct guess: %s.", string_correct);
    else
        $error("Incorrect Correct value. Expected: %s. Actual: %s.", string_correct, tb_correct);
end
endtask

//task to check if the letter guess changed
task guess_change;
input logic[7:0] expected_guess;
input string string_guess;
begin
    @(negedge tb_clk);
    tb_checking_outputs = 1'b1;
    if(tb_guess == expected_guess)
        $info("Guess Changed!: %s.", string_guess);
    else
        $error("Guess has not changed. Expected: %s. Actual: %s.", string_guess, tb_guess);
end
endtask

always begin
    tb_clk = 1'b0;
    #(CLK_PERIOD / 2.0);
    tb_clk = 1'b1;
    #(CLK_PERIOD / 2.0);
end

//DUT Portmap
Game_logic DUT(.clk(tb_clk),
            .nRst(tb_nRst),
            .guess(tb_guess),
            .setWord(tb_setWord),
            .toggle_state(tb_toggle_state),
            .letter(tb_letter),
            .red(tb_red), .green(tb_green),
            .mistake(tb_mistake), .red_busy(tb_red_busy),
            .game_rdy(tb_game_rdy), .numMistake(tb_numMistake),
            .correct(tb_correct));

//Main test bench process
initial begin
    //Signal dump
    $dumpfile("dump.vcd");
    $dumpvars;

    //initialize test bench signals
    tb_toggle_state = 1'b0;
    tb_nRst = 1'b1;
    tb_checking_outputs = 1'b0;
    tb_test_num = -1;
    tb_test_case = "Initializing";
    $display("/n/n%s", tb_test_case);

    //Wait some time before starting first test case
    #(0.1);

    //****************************************************
    //Test Case 0: Power-on-Reset of the DUT
    //****************************************************
    tb_test_num += 1;
    tb_test_case = "Test Case 0: Power-on-Reset of the DUT";
    $display("/n/n%s", tb_test_case);

    tb_toggle_state = 1'b1;
    tb_nRst = 1'b0;

    #(2);
    @(negedge tb_clk);
    @(negedge tb_clk);
    tb_nRst = 1'b1;

    tb_toggle_state = 1'b0;

    //****************************************************
    //Test Case 1: Testing incorrect guesses and loss
    //****************************************************
    tb_test_num += 1;
    reset_dut();
    tb_test_case = "Test Case 1: Testing incorrect guesses";
    $display("/n/n%s", tb_test_case);

    tb_setWord = 40'b0100000101010000010100000100110001000101; //Word: APPLE
    tb_guess = 8'b01000011; //Guess: "C"

    single_button_press();
    #(CLK_PERIOD * 50);
    check_mistake(1, "1");

    tb_guess = 8'b01001010; //Guess: "J"
    #(CLK_PERIOD * 50);

    check_mistake(2, "2");

    tb_guess = 8'b01010001; //Guess: "Q"
    #(CLK_PERIOD * 50);

    check_mistake(3, "3");

    tb_guess = 8'b01010010; //Guess: "R"
    #(CLK_PERIOD * 50);

    check_mistake(4, "4");

    tb_guess = 8'b01001011; //Guess: "K"
    #(CLK_PERIOD * 50);

    check_mistake(5, "5");

    tb_guess = 8'b01001101; //Guess: "M"
    #(CLK_PERIOD * 50);

    check_mistake(6, "6");

    check_correct(0, "0");

    //****************************************************
    //Test Case 2: Testing correct guesses and win
    //****************************************************
    tb_test_num += 1;
    reset_dut();
    tb_test_case = "Test Case 2: Testing correct guesses";
    $display("/n/n%s", tb_test_case);

    tb_setWord = 40'b0100000101010000010100000100110001000101; //Word: APPLE
    tb_guess = 8'b01000001; //Guess: "A"

    single_button_press();
    #(CLK_PERIOD * 50);

    check_correct(1, "1");

    tb_guess = 8'b01010000; //Guess: "P"
    #(CLK_PERIOD * 50);

    check_correct(3, "3");

    tb_guess = 8'b01001100; //Guess: "L"
    #(CLK_PERIOD * 50);

    check_correct(4, "4");

    tb_guess = 8'b01000101; //Guess: "E"
    #(CLK_PERIOD * 50);

    check_correct(5, "5");

    check_mistake(0, "0");

    //****************************************************
    //Test Case 3: Testing Guess Change and correct/incorrect
    //****************************************************
    tb_test_num += 1;
    reset_dut();
    tb_test_case = "Test Case 3: Testing Guess Change with incorrect/correct answers";
    $display("/n/n%s", tb_test_case);

    tb_setWord = 40'b0100110101001111010011110101001001000101; //Word: MOORE
    tb_guess = 8'b01001101; //Guess: "M"

    single_button_press();
    #(CLK_PERIOD * 50);

    check_correct(1, "1");

    tb_guess = 8'b01000001; //Guess: "A"
    #(CLK_PERIOD * 50);

    check_mistake(1,"1");


end

endmodule

module Game_logic (
    input logic clk, nRst,
    input logic [7:0] guess,
    input logic [39:0] setWord,
    input logic toggle_state,
    output logic [7:0] letter,
    output logic red, green, mistake, red_busy, game_rdy,
    output logic [2:0] numMistake, correct
);
    logic [2:0] tempcorrect, tempmistake;
    logic [7:0] placehold;
    state_t nextState;
    logic [4:0] indexCorrect;
    state_t state;

    assign numMistake = 0;
    assign correct = 0;

    always_ff @(posedge clk, negedge nRst) begin
        if(~nRst) begin
            state <= SET;
            numMistake <= 0;
            correct <= 0;
        end else begin
            state <= nextState;
            numMistake <= tempmistake;
            correct <= tempcorrect;
        end
    end

    always_comb begin
        red_busy = 0;
        red = 0;
        green = 0;
        mistake = 0;
        tempcorrect = correct;
        tempmistake = numMistake;
        indexCorrect = 0;
        placehold = 0;

        case(state)
            SET: begin
                letter = 0;
                placehold = 0;
                //flip flop will set the word using a shift register
                game_rdy = 1;
                indexCorrect = 0;
                if(toggle_state)
                    nextState = L0;
                else
                    nextState = SET;
            end
            L0: begin
                letter = 0;
                placehold = guess;
                red_busy = 1;
                game_rdy = 0;
                if(guess == setWord[39:32])begin
                    tempcorrect = correct + 1;
                    indexCorrect[0] = 1;
                end else begin
                    tempcorrect = correct;
                    indexCorrect[0] = 0;
                end
                nextState = L1;
            end
            L1: begin
                letter = 0;
                placehold = guess;
                game_rdy = 0;
                if(guess == setWord[31:24])begin
                    tempcorrect = correct + 1;
                    indexCorrect[1] = 1;
                end else begin
                    tempcorrect = correct;
                    indexCorrect[1] = 0;
                end
                nextState = L2;
            end
            L2: begin
                letter = 0;
                placehold = guess;
                game_rdy = 0;
                if(guess == setWord[23:16])begin
                    tempcorrect = correct + 1;
                    indexCorrect[2] = 1;
                end else begin
                    tempcorrect = correct;
                    indexCorrect[2] = 0;
                end
                nextState = L3;
            end
            L3: begin
                letter = 0;
                placehold = guess;
                game_rdy = 0;
                if(guess == setWord[15:8])begin
                    tempcorrect = correct + 1;
                    indexCorrect[3] = 1;
                end else begin
                    tempcorrect = correct;
                    indexCorrect[3] = 0;
                end
                nextState = L4;
            end
            L4: begin
                letter = 0;
                placehold = guess;
                game_rdy = 0;
                if(guess == setWord[7:0])begin
                    tempcorrect = correct + 1;
                    indexCorrect[4] = 1;
                end else begin
                    tempcorrect = correct;
                    indexCorrect[4] = 0;
                end
                nextState = STOP;
            end
            STOP: begin
                letter = 0;
                placehold = placehold;
                letter = guess;
                if(correct > 0) begin
                    tempmistake = 0;
                    mistake = 0;
                end else begin
                    mistake = 1;
                    tempmistake = numMistake + 1;
                end
                red_busy = 0;
                game_rdy = 1;
                if(correct == 5) begin
                    green = 1;
                    red = 0;
                    //LCD DISPLAY WIN
                end else if(numMistake == 6) begin
                    green = 0;
                    red = 1;
                    //LCD DISPLAY FAIL
                end
                if(placehold != guess) begin
                    nextState = L0;
                end else begin
                    nextState = STOP;
                end

            end
            default: begin
                letter = 0;
                placehold = 0;
                game_rdy = 0;
                nextState = SET;
            end
        endcase
    end
endmodule
