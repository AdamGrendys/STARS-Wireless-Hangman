/* UART Transmitter File
Descriuption: x
*/

`timescale 1ms / 100us

typedef enum logic [2:0] {
IDLE = 3'b001, START = 3'b010, DATAIN = 3'b011, STOP = 3'b100, CLEAN = 3'b101, PARITY = 3'b110
} curr_state;

module TBUART_Tx ();

// Testbench ports
localparam CLK_PERIOD = 10; // 100 Hz clk
logic tb_clk, tb_nRst, tb_tx_ctrl, tb_transmit_rdy, tb_tx_serial;
logic [7:0] tb_byte;
logic exp_serial, exp_rdy;

// Clock generation block
always begin
    tb_clk = 1'b0; 
    #(CLK_PERIOD / 2.0);
    tb_clk = 1'b1; 
    #(CLK_PERIOD / 2.0); 
end

uart_tx transmit(.clk(tb_clk), .nRst(tb_nRst), .tx_ctrl(tb_tx_ctrl), .tx_serial(tb_tx_serial), .tx_byte(tb_byte), .transmit_ready(tb_transmit_rdy));

initial begin
    $dumpfile("dump.vcd");
    $dumpvars;

    tb_nRst = 1'b1;
    tb_tx_ctrl = 1'b0;
    tb_byte = 8'b10011101;

     #(0.1);
    // ***********************************
    // Test Case 0: Power-on-Reset 
    // ***********************************
    // Reset DUT Task
    @(negedge tb_clk);
    tb_nRst = 1'b0; 
    @(negedge tb_clk);
    @(negedge tb_clk);
    tb_nRst = 1'b1;
    @(posedge tb_clk);

    // ***********************************
    // Test Case 0: Idle state of the transmitter 
    // ***********************************
    tb_nRst = 1'b1;
    tb_tx_ctrl = 1'b0;
    tb_byte = 8'b10011101;
    #(0.1);

    #30;

    // ***********************************
    // Test Case 0: Idle state of the transmitter 
    // ***********************************




end


endmodule













module uart_tx
#(
    parameter Clkperbaud = 1250
)

(
    input logic clk, nRst, tx_ctrl,
    input logic [7:0] tx_byte, 
    output logic transmit_ready, tx_serial
);
    logic [2:0] bit_index, next_bit_index;  
    logic [10:0] clk_count, next_clk_count;
    logic [3:0] pcount, count;
    curr_state state, next_state;

    always_ff @(posedge clk, negedge nRst) begin// flip flop to update states and counter
        if (~nRst) begin
            state <= IDLE;
            count <= 0;
            clk_count <= 0;
            bit_index <= 0;
        end else begin   
            state <= next_state;
            count <= pcount;
            clk_count <= next_clk_count;
            bit_index <= next_bit_index;
        end
    end
 
    always_comb begin
        case (state)
            IDLE: begin 
                tx_serial = 1; 
                transmit_ready = 1; 
                next_bit_index = 0; 
                pcount = 0;
                next_clk_count = 0;

                if (tx_ctrl == 1) begin //state transition logic
                    next_state = START;
                end else begin  
                    next_state = IDLE;
                end
            end
            START: begin 
                tx_serial = 0;
                transmit_ready = 0;
                next_bit_index = 0;
                pcount = 0;


                if(clk_count < Clkperbaud - 1) begin
                next_clk_count = clk_count + 1;
                next_state = START;
                end
                else begin
                next_clk_count = 0;
                next_state = DATAIN;
                end
            end
            DATAIN: begin   
                transmit_ready = 0;
                tx_serial = tx_byte[bit_index];
                
                if(clk_count < Clkperbaud - 1) begin
                next_clk_count = clk_count + 1;
                next_state = DATAIN;
                pcount = count;
                next_bit_index = bit_index;
                end
                else begin
                next_clk_count = 0; 
                if(tx_serial == 1) begin // parity counter counts 1s
                pcount = count + 1;
                end
                else begin
                pcount = count;
                end
            
                if (bit_index < 7) begin // state transition logic
                next_bit_index = bit_index + 1;
                next_state = DATAIN;
                end else  begin 
                next_bit_index = 0;
                next_state = PARITY;
                end
                end
            end 
            PARITY: begin
                next_bit_index = 0;
                transmit_ready = 0;
                
                if(pcount % 2 == 1) begin //Parity assignment 
                tx_serial = 1;
                pcount = 0;
                end
                else begin
                tx_serial = 0;
                pcount = 0;
                end
                
                if(clk_count < Clkperbaud - 1) begin
                next_clk_count = clk_count + 1;
                next_state = PARITY;
                end
                else begin
                next_clk_count = 0;
                next_state = STOP; // state transition logic
                end
            end
            STOP: begin 
                pcount = 0;
                tx_serial = 1;
                next_bit_index = 0;
                transmit_ready = 0;

                if(clk_count < Clkperbaud - 1) begin
                next_clk_count = clk_count + 1;
                next_state = STOP;
                end
                else begin
                next_clk_count = 0;
                next_state = CLEAN; // state transition logic
                end


                next_state = CLEAN; // state transition logic
                end
            CLEAN: begin 
                next_bit_index = 0;
                transmit_ready = 0;
                tx_serial = 1;
                pcount = 0;
                next_clk_count =0;

                next_state = IDLE; // state transition logic
                end
            default: begin 
                next_state = IDLE;
                next_bit_index = 0;
                transmit_ready = 0;
                tx_serial = 1;
                pcount = 0;
                next_clk_count = 0;
                end
        endcase
    end
endmodule