/*
    Module Name: shift_reg
    Description: Shift Register with multiple mode options
*/

module shift_reg
(
    input  logic clk, nRst, ready,
    input  logic [7:0] data,
    output logic [39:0] P
);
    logic [39:0] next_P;

    always_ff @(posedge clk, negedge nRst) begin
        if (~nRst)
            P <= 40'd0;
        else
            P <= next_P;
    end

    always_comb begin
	if (ready)
        	next_P = {P[31:0], data};
	else
		next_P = P;
    end
endmodule
