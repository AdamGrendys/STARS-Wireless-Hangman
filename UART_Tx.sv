/* UART Transmitter File
Descriuption: x
*/

typedef enum logic [2:0] {
IDLE = 3'b001, START = 3'b010, DATAIN = 3'b011, STOP = 3'b100, CLEAN = 3'b101, PARITY = 3'b110
} curr_state;

module uart_tx (
    input logic clk, nRst, tx_ctrl,
    input logic [7:0] tx_byte, 
    output logic transmit_ready, tx_serial
);
    logic [2:0] bit_index, counter;
    logic [7:0] data;
    logic [3:0] pcount, count;
    curr_state state, next_state;

    always_ff @(posedge clk, negedge nRst) 
        if (~nRst) begin
            state <= IDLE;
            count <= 0;
        end else begin   
            state <= next_state;
            count <= pcount;
        end
 
    always_comb begin
        case (state)
            IDLE: begin 
                tx_serial = 1; 
                transmit_ready = 1; 
                bit_index = 0; 
                pcount = 0;
                if (tx_ctrl == 1) begin    
                    data = tx_byte;
                    next_state = START;
                end else begin  
                    next_state = IDLE;
                    data = tx_byte;
                end
                end
            START: begin 
                tx_serial = 0;
                transmit_ready = 0;
                bit_index = 0;
                data = tx_byte;
                pcount = 0;
                // WAIT BAUD CYCLE COUNTER HERE
                next_state = DATAIN;
                end
            DATAIN: begin   
                data = tx_byte;
                tx_serial = data[bit_index];
                if(tx_serial == 1) begin
                pcount = count + 1;
                end
                else begin
                pcount = count;
                end
                transmit_ready = 0;
            
                if (bit_index < 7) begin
                    bit_index = bit_index + 1;
                    next_state = DATAIN;
                end else  begin 
                    bit_index = 0;
                    next_state = PARITY;
                end
                end 
            PARITY: begin
                data = tx_byte;
                bit_index = 0;
                transmit_ready = 0;
                if(pcount % 2 == 1) begin
                tx_serial = 1;
                pcount = 0;
                end
                else begin
                tx_serial = 0;
                pcount = 0;
                end
                next_state = STOP;
            end
            STOP: begin 
                pcount = 0;
                tx_serial = 1;
                bit_index = 0;
                data = tx_byte;
                // WAIT BAUD CYCLE HERE 
                transmit_ready = 0;
                next_state = CLEAN;
                end
            CLEAN: begin 
                next_state = IDLE;
                data = tx_byte;
                bit_index = 0;
                transmit_ready = 0;
                tx_serial = 1;
                pcount = 0;
                end
            default: begin 
                next_state = IDLE;
                data = tx_byte;
                bit_index = 0;
                transmit_ready = 0;
                tx_serial = 1;
                pcount = 0;
                end
        endcase
    end
endmodule