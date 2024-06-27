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
        guesses <= {8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111, 8'b01011111}; // _ x10 in ASCII
    end else begin
        guesses <= next_guess;
    end
end

always_comb begin
    if (ready) begin
        next_guess = {msg, guesses[79:8]};
        row1 = {56'b0, msg, 64'b0};
        row2 = {guesses, 48'b0};
    end
    else begin
        next_guess = guesses;
        row1 = {56'b0, msg, 64'b0};
        row2 = {guesses, 48'b0};
    end
end
endmodule