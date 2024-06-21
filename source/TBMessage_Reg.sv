/* Message Register File
Descriuption: x
*/

typedef enum logic [1:0] {
IDLE = 2'b00, WAIT = 2'b01, TRANSMIT = 2'b11
} curr_state;

module msg_reg (
    input logic clk, nRst, ready, transmit_ready,
    input logic [7:0] data,
    output logic blue, tx_ctrl,
    output logic [7:0] tx_byte
);

logic [7:0] msg, msg_rdy;
curr_state state, next_state;

always_ff @(posedge clk, negedge nRst) begin
    if (~nRst) begin 
        msg <= 8'b0;
        state <= IDLE;
    end else begin 
        msg <= msg_rdy;
        state <= next_state;
    end
end

always_comb begin 
    case (state)
        IDLE: begin 
            tx_byte = 8'b11111111;
            tx_ctrl = 0;
            blue = 0;
            if (ready) begin
                msg_rdy = data;
                next_state = WAIT;
            end 
        end
        WAIT: begin 
            tx_ctrl = 1;
            msg_rdy = msg;
            if (transmit_ready)
                next_state = TRANSMIT;
            else  
                next_state = WAIT;
        end
        TRANSMIT: begin
            tx_ctrl = 1;
            blue = 1;
            tx_byte = msg;
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end
endmodule