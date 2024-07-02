module keypad_controller (
  input logic clk, nRst, enable, mode,
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
      scan_col <= 4'd0;

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
    if(mode) begin
      if ((|read_row)) // & (|scan_col))
        // Maintain selected column while input button being pressed (non-zero row)
        scan_col_next = scan_col;
      else if (enable)
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
            scan_col_next = 4'b1111;
        endcase
        else
        scan_col_next = scan_col;
    end else begin
      scan_col_next = 4'b1111;
    end
  end

  assign strobe = |((~Q1_delay) & (Q1));
  assign cur_key = (|read_row & |scan_col) ? ({read_row, scan_col}) : (8'd0);
endmodule