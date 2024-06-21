/* Keypad Controller
 * Description: TODO
 */

module keypad_controller (
    input logic clk, nRst,
    input logic [3:0] read_row,
    output logic [7:0] cur_key, // Input for keypad_fsm
    output logic strobe // Input for keypad_fsm
);
    logic [3:0] Q0, Q1, Q1_delay, scan_col;
    
    // Synchronizer and rising (positive) edge detector - 3 FFs
    always_ff @(posedge clk, negedge nRst) begin
        if (~nRst) begin
            Q0 <= 4'd0;
            Q1 <= 4'd0;
            Q1_delay <= 4'd0;
        end else begin
            Q0 <= read_row;
            Q1 <= Q0;
            Q1_delay <= Q1;
        end
    end

    always_comb begin
        for (int i = 0; i <= 3; i++) begin
            scan_col = 4'd0;

            if (nRst) begin
                scan_col[i] = 1;

                if (i == 3) begin
                    i = -1;
                end
            end
        end
    end

    assign strobe = |((~Q1_delay) & (Q1));
    assign cur_key = {read_row, scan_col};

endmodule