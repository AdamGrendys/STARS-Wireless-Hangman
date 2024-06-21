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
    if (~nRst) begin
        guesses <= 0;
        row1 <= 0;
        row2 <= 0;
    end else begin
        guesses <= next_guess;
        row1 <= {60'b0, msg, 60'b0};
        row2 <= {guesses, 48'b0};
    end
end


always_comb begin
    if (ready)
        next_guess = {msg, guesses[71:0]};
    else    
        next_guess = guesses;
end
endmodule