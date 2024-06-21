/* UART Reciever File
Descriuption: x
*/
typedef enum logic [2:0] {
IDLE = 3'b001, START = 3'b010, DATAIN = 3'b011, STOP = 3'b100, CLEAN = 3'b101, PARITY = 3'b110
} curr_state;

module uart_rx (
    input logic clk, nRst, rx_serial, rec_ready,
    output logic rx_ready,
    output logic [7:0] rx_byte
);

logic [7:0] temp_byte;
curr_state state, next_state;

always_ff @(posedge clk, negedge nRst) begin
    if (~nRst) begin
        rx_byte <= 0;
        state <= IDLE;
    end else begin
        state <= next_state;
        rx_byte <= temp_byte;
    end
end

always_comb begin
    case (state)
        IDLE: begin
        end
        START: begin
        end
        DATAIN: begin
        end
        STOP: begin
        end
        CLEAN: begin 
        end
        default: begin
        end
    endcase
end

endmodule