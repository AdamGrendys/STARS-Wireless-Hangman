/* Game Logic File
Descriuption: Controls the states of the game where the host can confirm the word.
Then the next state compares the user input with the different letters in the word.
Finally, once the user either guesses the word, or gets 6 wrong questions, the game
ends. 
*/
typedef enum logic [2:0] { 
    SET = 0, L0 = 1, L1 = 2, L2 = 3, L3 = 4, L4 = 5, STOP = 6
} state_t;

module Game_logic (
    input logic clk, nRst,
    input logic [7:0] guess,
    input logic [39:0] setWord,
    input logic toggle_state,
    output logic [7:0] letter,
    output logic red, green, mistake, red_busy, game_rdy,
    output logic [2:0] numMistake, correct,
    output logic [4:0] indexCorrect
);
    logic [2:0] tempcorrect, tempmistake;
    logic [7:0] placehold;
    state_t nextState, state;
    logic [2:0] correctCount, mistakeCount;

    always_ff @(posedge clk, negedge nRst) begin
        if(~nRst) begin
            state <= SET;
            numMistake <= 0;
            correct <= 0;
        end else begin
            state <= nextState;
            numMistake <= mistakeCount;
            correct <= correctCount;
        end
    end

    always_comb begin
        red_busy = 0;
        red = 0;
        green = 0;
        mistake = 0;
        tempcorrect = 0;
        tempmistake = 0;
        indexCorrect = 0;
        correctCount = 0;
        mistakeCount = 0;
        placehold = 0;

        case(state)
            SET: begin
                letter = 0;
                placehold = 0;
                correctCount = 0;
                mistakeCount = 0;
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
                correctCount = correctCount;
                mistakeCount = mistakeCount;
                if(guess == setWord[39:32])begin
                    tempcorrect = tempcorrect + 1;
                    indexCorrect[0] = 1;
                end else begin
                    tempmistake = tempmistake + 1;
                    indexCorrect[0] = 0;
                end
                nextState = L1;
            end
            L1: begin
                letter = 0;
                placehold = guess;
                game_rdy = 0;
                correctCount = correctCount;
                mistakeCount = mistakeCount;
                if(guess == setWord[31:24])begin
                    tempcorrect = tempcorrect + 1;
                    indexCorrect[1] = 1;
                end else begin
                    tempmistake = tempmistake + 1;
                    indexCorrect[1] = 0;
                end
                nextState = L2;
            end
            L2: begin
                letter = 0;
                placehold = guess;
                game_rdy = 0;
                correctCount = correctCount;
                mistakeCount = mistakeCount;
                if(guess == setWord[23:16])begin
                    tempcorrect = tempcorrect + 1;
                    indexCorrect[2] = 1;
                end else begin
                    tempmistake = tempmistake + 1;
                    indexCorrect[2] = 0;
                end
                nextState = L3;
            end
            L3: begin
                letter = 0;
                placehold = guess;
                game_rdy = 0;
                correctCount = correctCount;
                mistakeCount = mistakeCount;
                if(guess == setWord[15:8])begin
                    tempcorrect = tempcorrect + 1;
                    indexCorrect[3] = 1;
                end else begin
                    tempmistake = tempmistake + 1;
                    indexCorrect[3] = 0;
                end
                nextState = L4;
            end
            L4: begin
                letter = 0;
                placehold = guess;
                game_rdy = 0;
                correctCount = correctCount;
                mistakeCount = mistakeCount;
                if(guess == setWord[7:0])begin
                    tempcorrect = tempcorrect + 1;
                    indexCorrect[4] = 1;
                end else begin
                    tempmistake = tempmistake + 1;
                    indexCorrect[4] = 0;
                end
                nextState = STOP;
            end
            STOP: begin
                letter = 0;
                placehold = placehold;
                letter = guess;
                if(tempcorrect > 0) begin
                    tempmistake = 0;
                    mistake = 0;
                    correctCount = correctCount + 1;
                end else begin
                    tempcorrect = 0;
                    mistake = 1;
                    mistakeCount = mistakeCount + 1;
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
                correctCount = 0;
                mistakeCount = 0;
            end
        endcase
    end
endmodule