/* Host display for game logic
Description: 
*/

module HostDisplay (
    input logic clk, nRst,
    input logic [4:0] indexCorrect,
    input logic [7:0] letter,
    input logic [2:0] numMistake, correct,
    input logic [39:0] word,
    input logic mistake,
    input logic gameEnd_host,
    output logic [127:0] top, bottom
);
    logic [127:0] nextTop;
    logic [127:0] nextBottom;
    logic [47:0] next_curr_guesses;
    logic [23:0] win = {8'h57, 8'h69, 8'h6E};  // Win in ASCII
    logic [31:0] lose = {8'h4C, 8'h6F, 8'h73, 8'h65}; // Lose in ASCII
    logic [39:0] curr_word; // _ _ _ _ _ in ASCII
    logic [47:0] curr_guesses; // _ _ _ _ _ _ in ASCII

always_ff @(posedge clk, negedge nRst) begin
    if(~nRst) begin
        top <= 0;
        bottom <= 0;
        curr_guesses <= 0;
    end else begin
        top <= nextTop;
        bottom <= nextBottom;
        curr_guesses <= next_curr_guesses;
    end
end



always_comb begin
next_curr_guesses = curr_guesses;
    case(mistake)
        0: begin
            if(gameEnd_host) begin
                curr_word = {8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111}; // _ _ _ _ _ in ASCII
                next_curr_guesses = {8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111}; // _ _ _ _ _ _ in ASCII
                nextTop = {44'b0, curr_word, 44'b0};
                nextBottom = {40'b0, curr_guesses, 40'b0};
            end
            else begin
                if(correct == 5) begin
                    nextTop = {52'b0, win, 52'b0};
                    nextBottom = {44'b0, word, 44'b0};
                end else begin
                    if(indexCorrect[4]) begin
                    curr_word[39:32] = letter;
                    end               
                    if(indexCorrect[3]) begin
                    curr_word[31:24] = letter;
                    end
                    if(indexCorrect[2]) begin
                    curr_word[23:16] = letter;
                    end
                    if(indexCorrect[1]) begin
                    curr_word[15:8] = letter;
                    end
                    if(indexCorrect[0]) begin
                    curr_word[7:0] = letter;
                    end

                    nextTop = {44'b0, curr_word, 44'b0};
                end
            end
        end 
        1: begin
            if(gameEnd_host) begin
                curr_word = {8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111}; // _ _ _ _ _ in ASCII
                next_curr_guesses = {8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111}; // _ _ _ _ _ _ in ASCII
                nextTop = {44'b0, curr_word, 44'b0};
                nextBottom = {40'b0, curr_guesses, 40'b0};
            end
            else begin
                if(numMistake == 6) begin
                    nextTop = {48'b0, lose, 48'b0};
                    nextBottom = {44'b0, word, 44'b0};
                end else begin
                    next_curr_guesses = {letter, curr_guesses[47:8]};//bottom row in position bit index becomes the guess letter
                    nextBottom = {40'b0, curr_guesses, 40'b0};
                end
            end 
        end
        default: begin
            curr_word = {8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111}; // _ _ _ _ _ in ASCII
            next_curr_guesses = {8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111}; // _ _ _ _ _ _ in ASCII
            nextTop = {44'b0, curr_word, 44'b0};
            nextBottom = {40'b0, curr_guesses, 40'b0};
        end
    endcase
end
endmodule