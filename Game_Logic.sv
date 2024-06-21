/* Game Logic File
Descriuption: Controls the states of the game where the host can confirm the word.
Then the next state compares the user input with the different letters in the word.
Finally, once the user either guesses the word, or gets 6 wrong questions, the game
ends. 
*/
typedef enum logic [2:0] { 
    SET = 0, L0 = 1, L1 = 2, L2 = 3, L3 = 4, L4 = 5, STOP = 6
} state_t;

module game_logic (
    input logic clk, nRst,
    input logic [7:0] guess,
    input logic [39:0] setWord,
    input logic enable, toggle_state,
    output logic red, green, letter, mistake, red_busy, game_rdy,
    output logic [2:0] numMistake, correct
);
    logic pos;
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
        letter = 0;
        red = 0;
        green = 0;
        mistake = 0;
        tempcorrect = 0;
        tempmistake = 0;
        game_rdy = 0;
        pos = 0;
        placehold = 0;
        indexCorrect = 0;

        case(state)
            SET: begin
                //flip flop will set the word using a shift register
                game_rdy = 1;
                indexCorrect = 0;
                if(toggle_state)
                    nextState = L0;
                else
                    nextState = SET;
            end
            L0: begin
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
                if(guess == setWord[31:24])begin
                    tempcorrect = correct + 1;
                    indexCorrect[0] = 1;
                end else begin
                    tempcorrect = correct;
                    indexCorrect[0] = 0;
                end
                nextState = L2;
            end
            L2: begin
                if(guess == setWord[23:16])begin
                    tempcorrect = correct + 1;
                    indexCorrect[0] = 1;
                end else begin
                    tempcorrect = correct;
                    indexCorrect[0] = 0;
                end
                nextState = L3;
            end
            L3: begin
                if(guess == setWord[15:8])begin
                    tempcorrect = correct + 1;
                    indexCorrect[0] = 1;
                end else begin
                    tempcorrect = correct;
                    indexCorrect[0] = 0;
                end
                nextState = L4;
            end
            L4: begin
                if(guess == setWord[7:0])begin
                    tempcorrect = correct + 1;
                    indexCorrect[0] = 1;
                end else begin
                    tempcorrect = correct;
                    indexCorrect[0] = 0;
                end
                nextState = STOP;
            end
            STOP: begin
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
                nextState = SET;
            end
        endcase

    end

endmodule