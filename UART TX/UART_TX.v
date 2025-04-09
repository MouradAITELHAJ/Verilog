module uart_tx(
    input clk,
    input reset,            // Active-low reset (matches your receiver)
    output reg tx_busy,      // Status output
    input [7:0] data_in,    // Data to transmit
    output reg tx           // Serial output
);

    // State encoding
    localparam IDLE     = 2'b00;
    localparam START    = 2'b01;
    localparam SENDING  = 2'b10;
    localparam STOP     = 2'b11;

    // Baudrate configuration (27MHz/9600 = 2813 cycles/bit)
    localparam CYCLE_PER_BIT = 2813;

    // Internal registers
    reg [1:0] state = IDLE;
    reg [12:0] cycle_counter;
    reg [2:0] bit_index;
    reg [7:0] data_reg;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            state <= IDLE;
            tx <= 1'b1;        // Idle high
            tx_busy <= 1'b0;
            cycle_counter <= 0;
            bit_index <= 0;
            data_reg <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    tx_busy <= 1'b0;
                    if (tx_start) begin
                        state <= START;
                        data_reg <= data_in;
                        tx_busy <= 1'b1;
                        cycle_counter <= 0;
                    end
                end
                
                START: begin
                    tx <= 1'b0;  // Start bit
                    if (cycle_counter == CYCLE_PER_BIT-1) begin
                        state <= SENDING;
                        cycle_counter <= 0;
                        bit_index <= 0;
                    end
                    else begin
                        cycle_counter <= cycle_counter + 1;
                    end
                end
                
                SENDING: begin
                    tx <= data_reg[bit_index];
                    if (cycle_counter == CYCLE_PER_BIT-1) begin
                        cycle_counter <= 0;
                        if (bit_index == 3'd7) begin
                            state <= STOP;
                        end
                        else begin
                            bit_index <= bit_index + 1;
                        end
                    end
                    else begin
                        cycle_counter <= cycle_counter + 1;
                    end
                end
                
                STOP: begin
                    tx <= 1'b1;  // Stop bit
                    if (cycle_counter == CYCLE_PER_BIT-1) begin
                        state <= IDLE;
                    end
                    else begin
                        cycle_counter <= cycle_counter + 1;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule