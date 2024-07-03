`default_nettype none
// Empty top module

module top (
  // I/O ports
  input  logic hz10M, reset,
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
  logic new_clk;

  clock_divider clock_div (.clk (hz10M),
                         .nRst (~reset),
                         .enable (1'b1),
                         .clear (~reset),
                         .max (21'd100000), //10000),
                         .at_max (new_clk));

  keypad_controller kc (.clk (hz10M),
                        .nRst (~reset), // Single key for simplicity
                        .read_row (pb[3:0]),
                        .enable (new_clk),
                        .cur_key (input_key), // Input for FSM
                        .strobe (discard_strobe), // Input for FSM
                        .scan_col (left[7:4]));
                        //.read_col_in (pb[3:0]),

                        //.sel_row (sel_row_out), //left[7:4]), // Temporary
                        //.sel_col (sel_col_out)); //left[3:0])); // Temporary

  //assign discard_scan_col = l;

  //assign pb[3:0] = sel_row_out;
  //assign right[3:0] = sel_row_out;

  logic [7:0] row_col;
  //assign row_col = {sel_row_out, sel_col_out};

  // Row (sel_row)
  ssdec ssdec7 (.in (pb[3:0]), //(row_col[7:4]),
                .enable (1'b1),
                .out (ss7[6:0]));

  // Column (sel_col)
  ssdec ssdec6 (.in (left[7:4]), //(row_col[3:0]),
                .enable (1'b1),
                .out (ss6[6:0]));
                
  ssdec ssdec4 (.in (cur_out[7:4]),
                .enable (1'b1),
                .out (ss4[6:0]));
                
  ssdec ssdec3 (.in (cur_out[3:0]),
                .enable (1'b1),
                .out (ss3[6:0]));
                

  logic discard_game_end;
  logic [7:0] discard_data, data_out, discard_temp_data, prev_key_out;
  logic [2:0] state_out;
  logic tog_state_disc;

  keypad_fsm key_fsm (.clk (hz10M),
                      .nRst (~reset), // Single key for simplicity
                      .strobe (discard_strobe), // Input from controller
                      .toggle_state (tog_state_disc),
                      .cur_key (input_key), // Input from controller
                      .cur_key_out (cur_out),
                      .prev_key (prev_key_out),
                      .ready (red), // Output
                      .data (right[7:0]),//right[7:0]), // Output
                      .state (state_out),
                      //.unlocked (left[7]),
                      .game_end (blue)); // TODO: Output

  ssdec_original ssdec0 (.in ({1'b0, state_out}),
                .enable (1'b1),
                .out (ss0[6:0]));
                
  assign green = discard_strobe;
  //assign = right[7:0];
  //assign left[7:0] = data_out;
  //assign right[7:0] = data_out;
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

module clock_divider (
  input logic clk, nRst, enable, clear,
  input logic [20:0] max,
  output logic at_max
);
  logic [20:0] next_count, count;
  
  always_ff @(posedge clk, negedge nRst) begin
    if (~nRst)
      count <= 0;
    else
      count <= next_count;
  end

  always_comb begin  
    //at_max = 0;
    at_max = (count == max);
    next_count = count;

    if (clear)
      next_count = 0;
    //else
      //at_max = (count == max);

    if (at_max)
      next_count = 0;
    else
      next_count = count + 1;
  end
endmodule

module keypad_controller (
  input logic clk, nRst, enable,
  input logic [3:0] read_row,
  output logic [7:0] cur_key, // Input for keypad_fsm
  output logic strobe, // Input for keypad_fsm
  output logic [3:0] scan_col//, sel_col, sel_row
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
      scan_col <= 4'b1111;

      // Temporary output variables for testing
      //sel_row <= 4'd0;
      //sel_col <= 4'd0;

    end else begin
      // Pass through FFs for stability and edge detection
      Q0 <= read_row;
      Q1 <= Q0;
      Q1_delay <= Q1;

      // Variables for testing purposes
      // Strobe should prompt transition in finite state machine (FSM) module
      // Only if there is an active column, on positive edge of button press (row)
      //if ((strobe) & (|scan_col)) begin
        //sel_row <= read_row;
        //sel_col <= scan_col_next;
      //end

      // Active column changes every clock cycle
      scan_col <= scan_col_next;
    end
  end

  always_comb begin
    // Setting active column for button press
    // Rate of switching reflected by all indicator lights turned on
    scan_col_next = scan_col;

    if (enable) begin
    if (|read_row)
      // Maintain selected column while input button being pressed (non-zero row)
      scan_col_next = scan_col;
    else //if (enable)
      case (scan_col)
        4'b1111:
          scan_col_next = 4'b0111;
        4'b0111:
          scan_col_next = 4'b1011;
        4'b1011:
          scan_col_next = 4'b1101;
        4'b1101:
          scan_col_next = 4'b1110;
        4'b1110:
          scan_col_next = 4'b0111;
        default:
          scan_col_next = 4'b1111; // scan_col
      endcase
      end
  end

  assign strobe = |((~Q1_delay) & (Q1));
  assign cur_key = (|read_row & |(~scan_col)) ? ({read_row, ~scan_col}) : (8'd0);
  //{read_row, scan_col}; //(|read_row & |scan_col) ? ({read_row, scan_col}) : (8'd0);
endmodule

module keypad_fsm (
  input logic clk, nRst, strobe,
  input logic [7:0] cur_key, // Concatenation of row and column


    output logic [7:0] cur_key_out,
      output logic [7:0] prev_key,


  // Temporarily set for FPGA testing
  output logic [2:0] state,
  /*output logic unlocked,

  */
  
  output logic ready, // Notification of letter submission after selection
  output logic game_end, // End-of-game signal
  output logic [7:0] data, // ASCII character from current key and number of consecutive presses
  output logic toggle_state // Notification of word submission
);
  logic [2:0] next_state; // state;
  //logic [7:0] prev_key, last_key;
  logic [7:0] temp_data, next_data;
  logic unlocked, next_unlocked;

  typedef enum logic [2:0] {
      INIT = 0, S0 = 1, S1 = 2, S2 = 3, S3 = 4, DONE = 5
  } keypad_state_t;

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
  /*
  ascii_encoder encoder (.row (last_key[7:4]),
                         .col (last_key[3:0]),
                         .state (next_state),
                         .ascii_character (temp_data));
  */

  function logic[7:0] ascii_character (input [3:0] row, col, input [2:0] state);
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
    
    if ((1 <= state) && (state <= 4)) begin // S0 through S3
      ascii_character += ({5'd0, state} - 8'd1);
    end
  endfunction

  // TODO: Verify through test benching

  always_ff @(posedge clk, negedge nRst) begin
    if (~nRst) begin
      //last_key <= 8'd0;

      state <= INIT;
      ready <= 1'b0;
      data <= 8'd0;
      
      unlocked <= 1'b0;
      prev_key <= 8'd0;

    end else begin
      //if (|cur_key)
        //last_key <= cur_key;

      //if (strobe) //& |last_key)
      state <= next_state;
      ready <= (state == DONE);
      data <= next_data;

      unlocked <= next_unlocked;
      // Prevent loading too early
      if ((unlocked) & |cur_key) // unlocked & |cur_key
        prev_key <= cur_key;
    end
  end

  always_comb begin
    cur_key_out = cur_key;

    // 0-1. By default
    next_state = state;
    next_data = data; // ascii_character(cur_key[7:4], cur_key[3:0], next_state);
    next_unlocked = unlocked;

    game_end = 1'b0;
    toggle_state = 1'b0;

    //if (state == DONE) begin
      //next_state = INIT;
      //next_data = 8'd0;
    //end

     if (state == DONE) begin
      next_state = INIT;
      next_data = 8'b01011111;
    end


    // Positive edge of pressing push button
    if (strobe & |cur_key) begin

      if ((cur_key == submit_letter_key) &&
          (state != INIT)) begin
        next_state = DONE;
        next_unlocked = 1'b1;
        // Note: ASCII character (data) has already been assigned
      
      end else if (cur_key == submit_word_key) begin
        next_state = INIT;
        next_data = 8'd0;
        toggle_state = 1'b1;
        next_unlocked = 1'b1;
      end

      // Invalid keys
      else
      if ((cur_key == key_1) ||
        (cur_key == key_A) ||
        (cur_key == key_B) ||
        (cur_key == key_D)) begin
        next_state = state;

      end else if ((cur_key == clear_key) || 
                   (cur_key == game_end_key)) begin
        next_state = INIT;
        next_data = 8'd0;

        if (cur_key == game_end_key)
          game_end = 1'b1;

        next_unlocked = 1'b1;

      /*
      end else if ((cur_key == submit_letter_key) && 
                   (state != INIT)) begin
        next_state = DONE;
        // Note: ASCII character (data) has already been assigned
        
        if (state == DONE) begin
          next_state = INIT;
          next_data = 8'd0;
        end
      */

      // Letter sets 2-9
      end else if (cur_key != submit_letter_key) begin
        if (prev_key == cur_key) begin
          if(state == INIT) begin
            next_state = S0;
          end else if (state == S0) begin
            next_state = S1;
          end else if (state == S1) begin
            next_state = S2;
          end else if (state == S2) begin
            next_state = ((cur_key == key_7) || (cur_key == key_9)) ? (S3) : (S0);
          end else if (state == S3) begin
            next_state = S0;
          end

        end else begin
          next_state = S0;
        end

        next_unlocked = 1'b1;
        next_data = ascii_character(cur_key[7:4], cur_key[3:0], next_state);
      end
      //end
    // Strobe is low
    end else begin
      next_unlocked = 1'b0;
    end

    //if (state == DONE) begin
      //next_state = INIT;
      //next_data = 8'd0;
      //next_unlocked = 1'b1;
    //end
  end
endmodule