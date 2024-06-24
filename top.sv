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
    logic [7:0] temp;

    keypad_controller kc (.clk (hz100),
                         .nRst (~reset),
                         .read_row (pb[7:4]),
                         .cur_key (temp),
                         .strobe (red),
                         .scan_col (left[7:4]));

    ssdec ssdec0 (.in (temp[3:0]),
                  .enable (1'b1),
                  .out (ss0[6:0]));

    ssdec ssdec1 (.in (temp[7:4]),
                  .enable (1'b1),
                  .out (ss1[6:0]));
endmodule

// Add more modules down here...
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
        /*
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
        */
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