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
logic [2:0] bit_index;
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
            rx_ready = 0;
            bit_index = 0;
            temp_byte = 0;
            bit_index = 0;

            if (rx_serial == 0 && rec_ready)
                next_state = START;
            else
                next_state = IDLE;
        end
        START: begin
            // wait half of baud cycle here
            rx_ready = 0;
            temp_byte = 0;
            bit_index = 0;

            if (rx_ready == 0 && rec_ready)
                next_state = DATAIN;
            else    
                next_state = START;
        end
        DATAIN: begin
            // wait for baud cycle 
            temp_byte[bit_index] = rx_serial;
            rx_ready = 0;

            if (bit_index < 7) begin
                bit_index = bit_index + 1;
                next_state = DATAIN;
            end else begin
                bit_index = 0;
                next_state = PARITY;
            end
        end
        PARITY: begin 
            /// SANDEEEPPPPP HELPPPPPPPPPP
            rx_ready = 0;
            temp_byte = 0;
            bit_index = 0;
            next_state = STOP;
        end
        STOP: begin
            // wait for baud cycle
            rx_ready = 1;
            temp_byte = 0;
            bit_index = 0;
            next_state = CLEAN;
        end
        CLEAN: begin 
            rx_ready = 0;
            temp_byte = 0;
            bit_index = 0;
            next_state = IDLE;
        end
        default: begin
            rx_ready = 0;
            temp_byte = 0;
            bit_index = 0;
            next_state = IDLE;
        end
    endcase
end
endmodule