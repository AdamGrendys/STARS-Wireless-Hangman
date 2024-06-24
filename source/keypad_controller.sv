module keypad_controller (
    input logic clk, nRst,
    input logic [3:0] read_row,
    output logic [7:0] cur_key, // Input for keypad_fsm
    output logic strobe, // Input for keypad_fsm
    output logic [3:0] scan_col
);
    logic [3:0] Q0, Q1, Q1_delay, scan_col_next;

    // Synchronizer and rising (positive) edge detector - 3 FFs
    always_ff @(posedge clk, negedge nRst) begin
        if (~nRst) begin
            Q0 <= 4'd0;
            Q1 <= 4'd0;
            Q1_delay <= 4'd0;
            scan_col <= 4'd0;
        end else begin
            Q0 <= read_row;
            Q1 <= Q0;
            Q1_delay <= Q1;
            scan_col <= scan_col_next;
        end
    end

    always_comb begin
        // Setting active column for button press, rate of switching reflected by all indicator lights turned on
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
            scan_col_next = scan_col;
        endcase
      
      /*
        for (int i = 0; i <= 3; i++) begin
          scan_col_next = 4'd0;

          if (~nRst) begin
            scan_col_next[i] = 1;

            if (i == 4) begin
              i = -1;
            end
          end
        end
      */
    end

    assign strobe = |((~Q1_delay) & (Q1));
    assign cur_key = {Q1_delay, scan_col};

endmodule