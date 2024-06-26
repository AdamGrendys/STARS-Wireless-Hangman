`default_nettype none
// Empty top module

module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);

  // Your code goes here...
  logic [7:0] input_key, ascii_char;
  logic [3:0] discard_scan_col, discard_row, discard_col;

  keypad_controller kc (.clk (hz100),
                        .nRst (~pb[19]), // Single key for simplicity
                        .read_row (pb[7:4]),
                        .cur_key (input_key), // Input for FSM
                        .strobe (green), // Input for FSM
                        .scan_col (discard_scan_col),
                        .sel_row (left[7:4]), //left[7:4]), // Temporary
                        .sel_col (left[3:0])); //left[3:0])); // Temporary

  // Row (sel_row)
  ssdec ssdec7 (.in (left[7:4]),
                .enable (1'b1),
                .out (ss7[6:0]));

  // Column (sel_col)
  ssdec ssdec6 (.in (left[3:0]),
                .enable (1'b1),
                .out (ss6[6:0]));

  logic discard_game_end;
  logic [7:0] discard_data;
  logic [7:0] char;
  
  ascii_encoder ae (.row (input_key[7:4]), .col (input_key[3:0]), .state (3'd0), .ascii_character (char));

  assign right[7:0] = char;

/*
  keypad_fsm key_fsm (.clk (hz100),
                      .nRst (~pb[19]), // Single key for simplicity
                      .strobe (green), // Input from controller
                      .key (input_key), // Input from controller
                      .ready (red), // Output
                      .data (discard_data), // Output
                      .temp_data (right[7:0]),
                      .cur_key (left[7:0]),
                      .game_end (discard_game_end)); // TODO: Output
*/
  //assign right [7:0] = input_key;

  //ssdec_original
  /*
  ssdec ssdec1 (.in (right[7:4]),
                         .enable (1'b1),
                         .out (ss1[6:0]));

  //ssdec_original
  ssdec ssdec0 (.in (right[3:0]),
                         .enable (1'b1),
                         .out (ss0[6:0]));
*/
  /*
  ssdec_original ssdec3 (.in (temp[3:0]),
                          .enable (1'b1),
                          .out (ss3[6:0]));

  ssdec_original ssdec4 (.in (temp[7:4]),
                          .enable (1'b1),
                          .out (ss4[6:0]));
  */
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
        default: out = 7'd0;
      endcase
    else // Turned off - push button unpressed
      out = 7'd0;
  end
endmodule

module keypad_controller (
  input logic clk, nRst,
  input logic [3:0] read_row,
  output logic [7:0] cur_key, // Input for keypad_fsm
  output logic strobe, // Input for keypad_fsm
  output logic [3:0] scan_col, sel_col, sel_row
);
  logic [3:0] Q0, Q1, Q1_delay;
  logic [3:0] scan_col_next, sel_col_next;

  // Synchronizer and rising (positive) edge detector - 3 FFs
  always_ff @(posedge clk, negedge nRst) begin
    if (~nRst) begin
      // Note: Strobe goes high when letting go of reset while holding push button
      Q0 <= 4'd0;
      Q1 <= 4'd0;
      Q1_delay <= 4'd0;

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

      // Variables for testing purposes
      // Strobe should prompt transition in finite state machine (FSM) module
      // Only if there is an active column, on positive edge of button press (row)
      if ((strobe) & (|scan_col)) begin
        sel_row <= read_row;
        sel_col <= scan_col_next;
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
  assign cur_key = ((|read_row) & (|scan_col)) ? ({read_row, scan_col}) : (8'd0);
endmodule

module keypad_fsm (
  input logic clk, nRst, strobe,
  input logic [7:0] key, // Concatenation of row and column
  output logic ready, // Notification of letter submission after selection
  output logic game_end, // End-of-game signal
  output logic [7:0] data, cur_key, temp_data // ASCII character from current key and number of consecutive presses
);
  logic [2:0] state, next_state;
  logic [7:0] prev_key; //, delayed_key;
  assign prev_key = 8'd0;
  logic [7:0] next_data;

  typedef enum logic [2:0] {
      INIT = 0, S0 = 1, S1 = 2, S2 = 3, S3 = 4, DONE = 5
  } keypad_state_t;

  always_ff @(posedge clk, negedge nRst) begin
    if (~nRst) begin
      state <= INIT;

      //delayed_key <= 8'd0;
      //cur_key <= 8'd0;
      //prev_key <= 8'd0;

      ready <= 1'b0;
      data <= 8'd0;
    end else begin
      state <= next_state;

      //delayed_key <= key;
      //cur_key <= delayed_key;
      //prev_key <= cur_key;

      ready <= (next_state == DONE);
      data <= next_data;
    end
  end

  always_ff @(posedge strobe, negedge nRst) begin
    if (~nRst) begin
      //delayed_key <= 8'd0;
      cur_key <= 8'd0;
      prev_key <= 8'd0;
    end else begin
      //delayed_key <= key;
      cur_key <= key;
      prev_key <= cur_key;
    end
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

  always_comb begin
    // 0. By default
    next_state = state;
    next_data = data;

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
      // 2-1. CLEAR
      // Should take priority over other push buttons
      if (cur_key == clear_key) begin
        next_state = INIT;
        next_data = 8'b0;

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

    //if (|{row, col})
    //  ascii_character += ({5'd0, state} - 8'd1);
  end
endmodule