module ascii_encoder (
  input logic [3:0] row, col,
  input logic [2:0] state,
  output logic [7:0] ascii_character
);

  always_comb begin
    ascii_character = 8'd0;

    if (row[0]) begin
      if (col[1])
        ascii_character = 8'd65;
      else
        ascii_character = 8'd68;

    end else if (row[1]) begin
      if (col[0])
        ascii_character = 8'd71;
      else if (col[1])
        ascii_character = 8'd74;
      else
        ascii_character = 8'd77;
    
    end else if (row[2]) begin
      if (col[0])
        ascii_character = 8'd80;
      else if (col[1])
        ascii_character = 8'd84;
      else
        ascii_character = 8'd87;
    end

    ascii_character += ({5'd0, state} - 8'd1);
  end
endmodule