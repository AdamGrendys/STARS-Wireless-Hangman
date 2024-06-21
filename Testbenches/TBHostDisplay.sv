/* Host display for game logic
Description: 
*/

module HostDisplay(
    input logic clk, nRst,
    input logic [4:0] indexCorrect,
    input logic [7:0] letter,
    input logic [2:0] numMistake, correct,
    input logic mistake,
    output [255:0] disp
);
    logic [127:0] nextTop;
    logic [127:0] nextBottom;

always_ff @(posedge clk, negedge nRst) begin
    if(~nRst) begin
        disp <= 256'b0;
    end else begin
        disp[255:0] <= {nextTop, nextBottom};
    end
end

always_comb begin
    case(mistake)
        0: begin
            if(correct == 5) begin
                //Top row becomes "win"
                //Bottom row displays the correct word
            end else begin
                //Top row in position bit index becomes the guess letter
            end
        end 
        1: begin
            if(numMistake == 6) begin
                //top row becomes "lose"
                //bottom row displays correct word
            end else begin
                //bottom row in position bit index becomes the guess letter
            end
        end
        default: begin
            //top row becomes 5 dashes
            //bottom row becomes 6 sets of "X_"
        end

    endcase
end


endmodule