/* Display FSM File
Descriuption: x
*/

module display_fsm (
    input logic clk, nRst, ready,
    input logic [7:0] msg,
    output logic [127:0] row1, row2
);

logic [79:0] guesses, next_guess;

always_ff @(posedge clk, negedge nRst) begin
    if (~nRst)
        guesses <= 0;
    else 
        guesses <= next_guess;
end


endmodule