module keypad_fsm (
  input logic clk, nRst, strobe,
  input logic [7:0] cur_key, // Concatenation of row and column
  
  // Temporarily set for FPGA testing
  output logic [2:0] state,
  output logic [7:0] prev_key,
  output logic unlocked,
  output logic [7:0] cur_key_out,
  
  output logic ready, // Notification of letter submission after selection
  output logic game_end, // End-of-game signal
  output logic [7:0] data // ASCII character from current key and number of consecutive presses
);
  // logic [2:0] state;
  logic [2:0] next_state;
  logic [7:0] temp_data, next_data;
  // logic [7:0] prev_key;
  // logic unlocked;

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
      
      if (unlocked) // Prevent loading too early
        prev_key <= cur_key;
    end
  end
  
  // 4-letter sets
  localparam key_7 = 8'b00101000; // R2 C0
  localparam key_9 = 8'b00100010; // R2 C2

  // Valid non-letter sets
  localparam submit_letter_key = 8'b00011000; // R3 C0
  localparam clear_key = 8'b00010100; // R3 C1
  localparam submit_word_key = 8'b00010010; // R3 C2
  localparam game_end_key = 8'b00100001; // R2 C3
  
  // Invalid non-letter sets
  localparam key_1 = 8'b10001000; // R0 C0
  localparam key_A = 8'b10000001; // R0 C3
  localparam key_B = 8'b01000001; // R1 C3
  localparam key_D = 8'b00010001; // R3 C3
  
  // Handle ASCII character conversion
  ascii_encoder encoder (.row (cur_key[7:4]),
                         .col (cur_key[3:0]),
                         .state (state),
                         .ascii_character (temp_data));

  // TODO: Check if ready signal high at right moment
  
  always_comb begin
    // 0-1. By default
    next_state = state;
    next_data = data;
    game_end = 1'b0;
    unlocked = 1'b0;

    // 0-2. No push button pressed
    if (!strobe) begin
      next_state = state;
    
    // 1. Invalid (inactive) push button pressed
    end else if ((cur_key == key_1) ||
       (cur_key == key_A) ||
       (cur_key == key_B) ||
       (cur_key == key_D) ||
       (cur_key == submit_word_key)) begin
      // Test Case: Make sure state doesn't change with invalid key as input
      // Invalid: 00 (1), 03 (A), 13 (B), 33 (D)
      // Submit Word: 23 (C)
      next_state = state;
      unlocked = 1'b0;

    // 2. Valid (active) push button pressed
    end else begin
      // Listing valid push button scenarios
      // 2-1. CLEAR or GAME END
      // Should take priority over other push buttons
      if ((cur_key == clear_key) || 
          (cur_key == game_end_key)) begin
        next_state = INIT;
        next_data = 8'd0;

        if (cur_key == game_end_key)
          game_end = 1'b1;

        if (cur_key == game_end_key)
          game_end = 1'b1;

      // 2-2. SUBMIT_LETTER
      end else if ((cur_key == submit_letter_key) && (state != INIT)) begin
        next_state = DONE;
        // Note: ASCII character (data) has already been assigned
        
        if (state == DONE) begin
          next_state = INIT;
          next_data = 8'd0;
        end

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
          end else if (state == S3) begin
            next_state = S0;
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
      
      // Allow cur_key to be loaded into prev_key (on the next strobe) only after cur_key has been initialized, post-reset
      unlocked = 1'b1;
    end
    
    cur_key_out = cur_key;
  end
endmodule