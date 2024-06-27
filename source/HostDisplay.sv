/* Host display for game logic
Description: 
*/

module HostDisplay (
    input logic clk, nRst,
    input logic [4:0] indexCorrect,
    input logic [7:0] letter,
    input logic [2:0] incorrect, correct,
    input logic [39:0] word,
    input logic mistake,
    input logic gameEnd_host,
    output logic [127:0] top, bottom
);
    logic [127:0] nextTop;
    logic [127:0] nextBottom;
    logic [47:0] next_curr_guesses;
    logic [23:0] win = {8'b01010111, 8'b01101001, 8'b01101110};  // Win in ASCII MAKE IT BINARY
    logic [31:0] lose = {8'b01001100, 8'b01101111, 8'b01110011, 8'b01100101}; // Lose in ASCII MAKE IT BINARY
    logic [39:0] curr_word, next_curr_word; // _ _ _ _ _ in ASCII
    logic [47:0] curr_guesses; // _ _ _ _ _ _ in ASCII

always_ff @(posedge clk, negedge nRst) begin
    if(~nRst) begin
        top <= 0;
        bottom <= 0;
        curr_guesses <= 0;
        curr_word <= {8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111};
    end else begin
        top <= nextTop;
        bottom <= nextBottom;
        curr_guesses <= next_curr_guesses;
        curr_word <= next_curr_word;
    end
end



always_comb begin
next_curr_guesses = curr_guesses;
next_curr_word = curr_word;
    case(mistake)
        0: begin
            if(gameEnd_host) begin
                next_curr_word = {8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111}; // _ _ _ _ _ in ASCII
                next_curr_guesses = {8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111}; // _ _ _ _ _ _ in ASCII
                nextTop = {48'b00100000, curr_word, 40'b00100000}; // split evenly by 8
                nextBottom = {40'b00100000, curr_guesses, 40'b00100000}; // split evenly by 8
            end
            else begin
                if(correct == 5) begin
                    nextTop = {56'b00100000, win, 48'b00100000}; // split evenly by 8
                    nextBottom = {48'b00100000, word, 40'b00100000}; // split evenly by 8
                end else begin
                    if(indexCorrect[4]) begin
                    next_curr_word[39:32] = letter;
                    end               
                    if(indexCorrect[3]) begin
                    next_curr_word[31:24] = letter;
                    end
                    if(indexCorrect[2]) begin
                    next_curr_word[23:16] = letter;
                    end
                    if(indexCorrect[1]) begin
                    next_curr_word[15:8] = letter;
                    end
                    if(indexCorrect[0]) begin
                    next_curr_word[7:0] = letter;
                    end

                    nextTop = {48'b00100000, curr_word, 40'b00100000}; // split evenly by 8
                end
            end
        end 
        1: begin
            if(gameEnd_host) begin
                next_curr_word = {8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111}; // _ _ _ _ _ in ASCII
                next_curr_guesses = {8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111}; // _ _ _ _ _ _ in ASCII
                nextTop = {48'b000100000, curr_word, 40'b00100000}; // split evenly by 8
                nextBottom = {40'b00100000, curr_guesses, 40'b00100000}; // split evenly by 8
            end
            else begin
                if(incorrect == 6) begin
                    nextTop = {48'b00100000, lose, 48'b00100000}; // split evenly by 8
                    nextBottom = {48'b00100000, word, 40'b00100000}; // split evenly by 8
                end else begin
                    next_curr_guesses = {letter, curr_guesses[47:8]};//bottom row in position bit index becomes the guess letter
                    nextBottom = {40'b00100000, curr_guesses, 40'b00100000}; // split evenly by 8
                end
            end 
        end
        default: begin
            next_curr_word = {8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111}; // _ _ _ _ _ in ASCII
            next_curr_guesses = {8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111}; // _ _ _ _ _ _ in ASCII
            nextTop = {48'b00100000, curr_word, 40'b00100000}; // split evenly by 8
            nextBottom = {40'b00100000, curr_guesses, 40'b00100000}; // split evenly by 8
        end 
    endcase
end
endmodule