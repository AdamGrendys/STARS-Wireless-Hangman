module keypad_fsm (
  input logic clk, nRst, strobe,
  input logic [7:0] cur_key, // Concatenation of row and column
  output logic ready, // Notification of letter submission after selection
  output logic game_end, // End-of-game signal
  output logic [7:0] data // ASCII character from current key and number of consecutive presses
);
  logic [2:0] state, next_state;
  logic [7:0] prev_key;
  logic [7:0] temp_data, next_data;

  typedef enum logic [2:0] {
      INIT = 0, S0 = 1, S1 = 2, S2 = 3, S3 = 4, DONE = 5
  } keypad_state_t;

  always_ff @(posedge clk, negedge nRst) begin
    if (~nRst) begin
      state <= INIT;
      ready <= 1'b0;
      data <= 8'd0;
      prev_key <= 8'd0;
    end else begin
      state <= next_state;
      ready <= (next_state == DONE);
      data <= next_data;
      if (strobe) // How to prevent changing too early?
        prev_key <= cur_key;
    end
  end

  always_ff @(posedge strobe, negedge nRst) begin
    if (~nRst) begin
      prev_key <= 8'd0;
    else
  end

  localparam key_7 = 8'b00101000; // R2 C0
  localparam key_9 = 8'b00100010; // R2 C2

  localparam submit_letter_key = 8'b00011000; // R3 C0
  localparam clear_key = 8'b00010100; // R3 C1
  localparam submit_word_key = 8'b00010010; // R3 C2
  localparam game_end_key = 8'b00100001; // R2 C3
  
  ascii_encoder encoder (.row (cur_key[7:4]),
                         .col (cur_key[3:0]),
                         .state (state),
                         .ascii_character (temp_data));

  // TODO: Check if ready signal high at right moment

  always_comb begin
    // 0. By default
    next_state = state;
    next_data = data;
    game_end = 1'b0;

    // 1. Invalid (inactive) or no push button pressed
    if ((!strobe) ||
      (cur_key == (8'b10000001 | 8'b01000001 | 8'b00010001 | 8'b10001000)) ||
      (cur_key == submit_word_key)) begin
      next_state = state;
      // Test Case: Make sure state doesn't change with invalid key as input

    // 2. Valid (active) push button pressed
    end else begin
      if (state == DONE) begin
        next_state = INIT;
      end

      // Listing valid push button scenarios
      // 2-1. CLEAR or GAME END
      // Should take priority over other push buttons
      if (cur_key == (clear_key | game_end_key)) begin
        next_state = INIT;
        next_data = 8'b0;

        if (cur_key == game_end_key)
          game_end = 1'b1;

      // 2-2. SUBMIT_LETTER
      end else if ((cur_key == submit_letter_key) && (state != INIT)) begin
        next_state = DONE;
        // Note: ASCII character (data) has already been assigned

      // 2-3. LETTER SETS 2 to 9
      end else begin
        // 2-3-1. Buttons match, so toggle and/or wrap around
        if (prev_key == cur_key) begin
          if (state == S0) begin
            next_state = S1;
          end else if (state == S1) begin
            next_state = S2;
          end else if (state == S2) begin
            next_state = ((cur_key == key_7) || (cur_key == key_9)) ? (S3) : (S0);
          end

        // 2-3-2. Buttons do not match (first or new letter set selected)
        end else begin
          // Note: (state == DONE) should never be the case here
          // Because of automatic transition to INIT (reset)
          next_state = S0;
        end

        // Update pre-submission data (current letter) to preview on display each time
        next_data = temp_data;
      end
    end
  end
endmodule