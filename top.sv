`default_nettype none
// Empty top module

module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right, ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);

  // Your code goes here...
  logic [7:0] input_key, cur_out;
  logic discard_strobe;
  logic [3:0] discard_scan_col, discard_row, discard_col, sel_row_out, sel_col_out;

  keypad_controller kc (.clk (hz100),
                        .nRst (~pb[19]), // Single key for simplicity
                        .read_row (pb[7:4]),
                        .cur_key (input_key), // Input for FSM
                        .strobe (discard_strobe), // Input for FSM
                        .scan_col (discard_scan_col),
                        .read_col_in (pb[3:0]),

                        .sel_row (sel_row_out), //left[7:4]), // Temporary
                        .sel_col (sel_col_out)); //left[3:0])); // Temporary

  logic [7:0] row_col;
  assign row_col = {sel_row_out, sel_col_out};

  // Row (sel_row)
  ssdec ssdec7 (.in (row_col[7:4]), //(row_col[7:4]),
                .enable (1'b1),
                .out (ss7[6:0]));

  // Column (sel_col)
  ssdec ssdec6 (.in (row_col[3:0]), //(row_col[3:0]),
                .enable (1'b1),
                .out (ss6[6:0]));
                
  ssdec ssdec4 (.in (prev_key_out[7:4]),
                .enable (1'b1),
                .out (ss4[6:0]));
                
  ssdec ssdec3 (.in (prev_key_out[3:0]),
                .enable (1'b1),
                .out (ss3[6:0]));

  logic discard_game_end;
  logic [7:0] discard_data, data_out, discard_temp_data, prev_key_out;
  logic [2:0] state_out;

  keypad_fsm key_fsm (.clk (hz100),
                      .nRst (~pb[19]), // Single key for simplicity
                      .strobe (discard_strobe), // Input from controller

                      .cur_key (input_key), // Input from controller
                      //.cur_key_out (cur_out),
                      .prev_key (prev_key_out),
                      .ready (red), // Output
                      .data (data_out),//right[7:0]), // Output
                      .state (state_out),
                      .unlocked (left[7]),
                      .game_end (blue)); // TODO: Output

  ssdec_original ssdec0 (.in ({1'b0, state_out}),
                .enable (1'b1),
                .out (ss0[6:0]));
                
  assign discard_strobe = green;
  //assign = right[7:0];
  //assign left[7:0] = data_out;
  assign right[7:0] = data_out;
  //assign right[2:0] = state_out;

endmodule

// Add more modules down here...
module ssdec_original (
  input logic [3:0] in,
  input logic enable,
  output logic [6:0] out
);
  always_comb begin
    if (enable) // Turned on - push button pressed
      case(in)
        4'd0: out = 7'b0111111;
        4'd1: out = 7'b0000110;
        4'd2: out = 7'b1011011;
        4'd3: out = 7'b1001111;
        4'd4: out = 7'b1100110;
        4'd5: out = 7'b1101101;
        4'd6: out = 7'b1111101;
        4'd7: out = 7'b0000111;
        4'd8: out = 7'b1111111;
        4'd9: out = 7'b1100111;
        4'hA: out = 7'b1110111;
        4'hB: out = 7'b1111100;
        4'hC: out = 7'b00111001;
        4'hD: out = 7'b1011110;
        4'hE: out = 7'b1111001;
        4'hF: out = 7'b1110001;
        default: out = 7'd0;
      endcase
    else // Turned off - push button unpressed
      out = 7'd0;
  end
endmodule

module ssdec (
  input logic [3:0] in,
  input logic enable,
  output logic [6:0] out
);
  always_comb begin
    if (enable) // Turned on - push button pressed
      case(in)
        4'b1000: out = 7'b0111111; // 0th row/column
        4'b0100: out = 7'b0000110; // 1st row/column
        4'b0010: out = 7'b1011011; // 2nd row/column
        4'b0001: out = 7'b1001111; // 3rd row/column
        4'd0: out = 7'b0001000;
        default: out = 7'd0;
      endcase
    else // Turned off - push button unpressed
      out = 7'd0;
  end
endmodule

module keypad_controller (
  input logic clk, nRst,
  input logic [3:0] read_row, read_col_in,
  output logic [7:0] cur_key, // Input for keypad_fsm
  output logic strobe, // Input for keypad_fsm
  output logic [3:0] scan_col, 
  output logic [3:0] sel_col, sel_row
);
  logic [3:0] Q0, Q1, Q1_delay;
  logic [3:0] scan_col_next, sel_col_next, read_col;

  // Synchronizer and rising (positive) edge detector - 3 FFs
  always_ff @(posedge clk, negedge nRst) begin
    if (~nRst) begin
      // Note: Strobe goes high when letting go of reset while holding push button
      Q0 <= 4'd0;
      Q1 <= 4'd0;
      Q1_delay <= 4'd0;
      
      read_col <= 4'd0;

      // Note: Deactivating the scanning of columns should prevent key input
      scan_col <= 4'd0;

      // Temporary output variables for testing
      sel_row <= 4'd0;
      sel_col <= 4'd0;

    end else begin
      // Pass through FFs for stability and edge detection
      Q0 <= read_row;
      Q1 <= Q0;
      Q1_delay <= Q1;
      
      read_col <= read_col_in;

      // Variables for testing purposes
      // Strobe should prompt transition in finite state machine (FSM) module
      // Only if there is an active column, on positive edge of button press (row)
      if ((strobe) & (|read_col)) begin// (|scan_col)) begin
        sel_row <= read_row;
        sel_col <= read_col_in; //scan_col_next;
      end

      // Active column changes every clock cycle
      scan_col <= scan_col_next;
    end
  end

  always_comb begin
    // Setting active column for button press
    // Rate of switching reflected by all indicator lights turned on
    if (|read_row)
      // Maintain selected column while input button being pressed (non-zero row)
      scan_col_next = scan_col;
    else
      case (scan_col)
        4'b0000:
          scan_col_next = 4'b1000;
        4'b1000:
          scan_col_next = 4'b0100;
        4'b0100:
          scan_col_next = 4'b0010;
        4'b0010:
          scan_col_next = 4'b0001;
        4'b0001:
          scan_col_next = 4'b1000;
        default:
          scan_col_next = 4'd0;
      endcase
  end

  assign strobe = |((~Q1_delay) & (Q1));
  assign cur_key = ((|read_row) & (|read_col_in)) ? ({read_row, read_col_in}) : (8'd0);
  //((|read_row) & (|scan_col)) ? ({read_row, scan_col}) : (8'd0);
endmodule

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
                         .state (next_state),
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

module ascii_encoder (
  input logic [3:0] row, col,
  input logic [2:0] state,
  output logic [7:0] ascii_character
);

  always_comb begin
    ascii_character = 8'd0;

    if (row[3]) begin // "0" - 1000
      if (col[2]) // "1" - 0100
        ascii_character = 8'd65;
      else if (col[1]) // "2" - 0010
        ascii_character = 8'd68;

    end else if (row[2]) begin // "1" - 0100
      if (col[3]) // "0" - 1000
        ascii_character = 8'd71;
      else if (col[2]) // "1" - 0100
        ascii_character = 8'd74;
      else if (col[1]) // "2" - 0010
        ascii_character = 8'd77;

    end else if (row[1]) begin // "2" - 0010
      if (col[3]) // "0" - 1000
        ascii_character = 8'd80;
      else if (col[2]) // "1" - 0100
        ascii_character = 8'd84;
      else if (col[1]) // "2" - 0010
        ascii_character = 8'd87;
    end
    
    if ((1 <= state) && (state <= 4)) // S0 through S3
      ascii_character += ({5'd0, state} - 8'd1);
  end
endmodule