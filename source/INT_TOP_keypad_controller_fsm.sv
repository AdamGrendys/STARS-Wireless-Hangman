/* Keypad Controller and Keypad FSM Integration Module
 * Description: ...
 */

module INT_TOP_keypad_controller_fsm (
    input logic clk, nRst,
    input logic [3:0] read_row,
    output logic ready, game_end, toggle_state,
    output logic [7:0] data
);
    logic [7:0] cur_key;
    logic [3:0] scan_col;
    logic strobe, new_clk;

/*
clock_divider clock_div (.clk (clk),
                         .nRst (nRst),
                         .enable (1'b1),
                         .clear (~nRst),
                         .max (7'd100),
                         .at_max (new_clk));
*/

keypad_controller kc (.clk (clk),
                      .nRst (nRst),
                      .enable (1'b1),
                      .read_row (read_row),
                      .cur_key (cur_key),
                      .strobe (strobe),
                      .scan_col (scan_col));
                
keypad_fsm key_fsm (.clk (clk),
                    .nRst (nRst),
                    .strobe (strobe),
                    .cur_key (cur_key),
                    .ready (ready),
                    .game_end (game_end),
                    .data (data),
                    .toggle_state (toggle_state));
endmodule