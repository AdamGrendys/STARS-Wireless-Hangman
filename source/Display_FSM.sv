/* Display FSM File
Descriuption: x
*/

module Display_FSM (
    input logic clk, nRst, ready,
    input logic [7:0] msg,
    output logic [127:0] row1, row2
);

logic [79:0] guesses, next_guess;

always_ff @(posedge clk, negedge nRst) begin
    if (~nRst) begin
        guesses <= {8'h5F, 8'h5F, 8'h5F, 8'h5F, 8'h5F, 8'h5F, 8'h5F, 8'h5F, 8'h5F, 8'h5F}; // _ x10 in ASCII
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
        next_guess = {msg, guesses[79:8]};
    else    
        next_guess = guesses;
end
endmodule