/* Keypad Controller and Keypad FSM Integration Module
 * Description: ...
 */

module keypad_controller_fsm_int_top (
    input logic clk, nRst,
    input logic [3:0] read_row,
    output logic ready, game_end, toggle_state,
    output logic [7:0] data
);
    logic [7:0] cur_key;
    logic [3:0] scan_col;
    logic strobe, new_clk;

clock_divider clock_div (.clk (clk),
                         .nRst (nRst),
                         //.clear (~nRst),
                         .max (17'd100000),
                         .at_max (new_clk));

keypad_controller kc (.clk (clk),
                      .nRst (nRst),
                      .read_row (read_row),
                      .cur_key (cur_key),
                      .enable (1'b1), //new_clk),
                      .mode (1'b1),
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
