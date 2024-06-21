/* Game Logic File
Descriuption: Controls the states of the game where the host can confirm the word.
Then the next state compares the user input with the different letters in the word.
Finally, once the user either guesses the word, or gets 6 wrong questions, the game
ends. 
*/
typedef enum logic [2:0] { 
    SET = 0, L0 = 1, L1 = 2, L2 = 3, L3 = 4, L4 = 5, END = 6
} state_t;

module game_logic (
    input logic clk, nRst,
    input logic [7:0] guess,
    input logic [39:0] setWord,
    input logic enable,
    output logic [2:0] state,
    output logic red, green, letter, mistake, correct, tempmistake, red_busy,
    output logic numMistake
);
    logic pos;
    logic tempcorrect;
    logic [7:0] placehold;
    logic [2:0] nextState;
    logic [4:0] indexCorrect;

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
        pos = 0;

        case(state) 
            SET: begin
                //flip flop will set the word using a shift register


            end




        endcase

    end

endmodule