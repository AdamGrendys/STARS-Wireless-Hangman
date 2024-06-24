/* Host display for game logic
Description: 
*/

module HostDisplay(
    input logic clk, nRst,
    input logic [4:0] indexCorrect,
    input logic [7:0] letter,
    input logic [2:0] numMistake, correct,
    input logic [39:0] word,
    input logic mistake,
    output [127:0] top, bottom
);
    logic [127:0] nextTop;
    logic [127:0] nextBottom;

always_ff @(posedge clk, negedge nRst) begin
    if(~nRst) begin
        top <= 0;
        bottom <= 0;
    end else begin
        top <= nextTop;
        bottom <= nextBottom;
    end
end

logic [23:0] win = {8'h57, 8'h69, 8'h6E};  // Win in ASCII
logic [31:0] lose = {8'h4C, 8'h6F, 8'h73, 8'h65}; // Lose in ASCII
logic [39:0] curr_word = {8'h5F, 8'h5F, 8'h5F, 8'h5F, 8'h5F}; // _ _ _ _ _ in ASCII
logic [47:0] curr_guesses = {8'h5F, 8'h5F, 8'h5F, 8'h5F, 8'h5F, 8'h5F}; // _ _ _ _ _ _ in ASCII

always_comb begin
    case(mistake)
        0: begin
            if(correct == 5) begin
                nextTop = {52'b0, win, 52'b0};
                nextBottom = {44'b0, word, 44'b0};
            end else begin
                curr_word[indexCorrect] = letter;  //Top row in position bit index becomes the guess letter
                nextTop = {44'b0, curr_word, 44'b0};
            end
        end 
        1: begin
            if(numMistake == 6) begin
                nextTop = {48'b0, lose, 48'b0};
                nextBottom = {44'b0, word, 44'b0};
            end else begin
                curr_guesses = ... //bottom row in position bit index becomes the guess letter
                nextBottom = {40'b0, curr_guesses, 40'b0};
            end
        end
        default: begin
            curr_word = {8'h5F, 8'h5F, 8'h5F, 8'h5F, 8'h5F}; // _ _ _ _ _ in ASCII
            curr_guesses = {8'h5F, 8'h5F, 8'h5F, 8'h5F, 8'h5F, 8'h5F}; // _ _ _ _ _ _ in ASCII
            nextTop = {44'b0, curr_word, 44'b0};
            nextBottom = {40'b0, curr_guesses, 40'b0};
        end
    endcase
end
endmodule