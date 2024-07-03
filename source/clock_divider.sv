module clock_divider (
  input logic clk, nRst,
  input logic [16:0] max,
  output logic at_max
);
  logic [16:0] next_count, time_o;
  
  always_ff @(posedge clk, negedge nRst) begin
    if (~nRst)
      time_o <= 0;
    else
      time_o <= next_count;
  end

  // Next state logic
  assign at_max = (time_o == max);

  always_comb begin    
    if (~nRst)
      next_count = 0;
    else
      next_count = (at_max) ? (0) : (time_o + 1);
  end
endmodule