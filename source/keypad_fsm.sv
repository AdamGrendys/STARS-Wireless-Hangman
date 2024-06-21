/* Keypad FSM
 * Description: TODO
 */

module keypad_fsm (
    input clk, nRst, strobe,
    input logic [7:0] cur_key, // Concatenation of row and column
    
    output logic ready,
    output logic [7:0] data
);
    logic [2:0] state, next_state;
    logic [7:0] prev_key, next_data;
    assign prev_key = 8'd0;

    always_ff @(posedge clk, negedge nRst) begin
        if (~nRst) begin // Separate from clear button???
            state <= INIT;
            prev_key <= 8'd0;
            ready <= 1'b0;
        end else begin
            state <= next_state;
            prev_key <= cur_key;
            ready <= (next_state == DONE);
            data <= next_data;
        end
    end

     typedef enum logic [2:0] {
        INIT = 0, S0 = 1, S1 = 2, S2 = 3, S3 = 4, DONE = 5
    } keypad_state_t;

    // localparam key_2 = 8'b1000 0100; // R0 C1
    // localparam key_3 = 8'b1000 0010; // R0 C2

    // localparam key_4 = 8'b0100 1000; // R1 C0
    // localparam key_5 = 8'b0100 0100; // R1 C1
    // localparam key_6 = 8'b0100 0010; // R1 C2

    localparam key_7 = 8'b00101000; // R2 C0
    // localparam key_8 = 8'b0010 0100; // R2 C1
    localparam key_9 = 8'b00100010; // R2 C2

    localparam submit_letter_key = 8'b00011000; // R3 C0
    localparam clear_key = 8'b00010100; // R3 C1
    localparam submit_word_key = 8'b00010010; // R3 C2

    localparam invalid_key = 8'b10001000; // R0 C0
    localparam invalid_col = 4'b0001; // C3

    function logic [7:0] get_ascii_from_key (logic [3:0] row, logic [3:0] col);
        if (row[0]) begin
            return (col[1]) ? (8'd65) : (8'd68);

        end else if (row[1]) begin
            return (col[0]) ? (8'd71) : ((col[1]) ? (8'd74) : (8'd77));
        
        end else if (row[2]) begin
            return (col[0]) ? (8'd80) : ((col[1]) ? (8'd84) : (8'd87));
        end
    endfunction
    
    always_comb begin
        // By default
        next_state = state;
        next_data = data;

        /* 1. Invalid (inactive) or no push button pressed */
        if ((!strobe) || (cur_key == submit_word_key) || 
            (cur_key == invalid_key) || (cur_key[3:0] == invalid_col)) begin
            next_state = state;

        /* 2. Valid (active) push button pressed */
        end else begin
            if (state == DONE) begin
                next_state = INIT;
            end

            /* Listing valid push button scenarios */
            /* 2-1. CLEAR */
            // Should take priority over other push buttons
            if (cur_key == clear_key) begin
                next_state = INIT;
                next_data = 8'b0;

            /* 2-2. SUBMIT_LETTER */
            end else if ((cur_key == submit_letter_key) && (state != INIT)) begin
                next_state = DONE;
                // Note: ASCII character (data) has already been assigned

            /* 2-3. LETTER SETS 2 to 9 */
            end else begin
                /* 2-3-1. Buttons match, so toggle and/or wrap around */
                if (prev_key == cur_key) begin
                    if (state == S0) begin
                        next_state = S1;
                    end else if (state == S1) begin
                        next_state = S2;
                    end else if (state == S2) begin
                        next_state = ((cur_key == key_7) || (cur_key == key_9)) ? (S3) : (S0);
                    end

                /* 2-3-2. Buttons do not match (first or new letter set selected) */
                end else begin
                    // Note: (state == DONE) should never be the case here
                    // Because of automatic transition to INIT (reset)
                    next_state = S0;
                end

                // Update pre-submission data (current letter) to preview on display each time
                next_data = get_ascii_from_key(cur_key[7:4], cur_key[3:0]) + ({5'd0, state} - 1);
            end
        end
    end

endmodule