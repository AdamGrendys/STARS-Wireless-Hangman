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