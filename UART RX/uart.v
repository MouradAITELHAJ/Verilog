module uart_rx (
    input clk,              
    input reset,             
    input rx,                // UART receive line
    output reg [7:0] data_out //data received 
);

    // State encoding
    localparam IDLE     = 2'b00;
    localparam START    = 2'b01;
    localparam SAMPLING = 2'b10;
    localparam STOP     = 2'b11;

    /* Baudrate configuration for 27 MHz clock and 9600 baud
     number of clock cycles per bit will be 27 000 000 devided by 9600
     the result is 2812.5, we take 2813*/
    localparam COUNTER_LIMIT = 2813; 
    localparam SAMPLE_POINT  = 1406; // Middle of the bit (simpling in uart happens at the middle)

    // Internal registers
    reg [1:0] state = IDLE;
    reg [12:0] counter = 0;        // Counter for baud rate timing
    reg [2:0] data_counter = 0;    // Counter for data bits
    reg [7:0] data_reg = 0;        // Shift register for received data

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            // Reset all registers
            state <= IDLE;
            data_out <= 0;
            counter <= 0;
            data_counter <= 0;
            data_reg <= 0;
        end else begin
            case (state)
                IDLE: begin
                    // Wait for the start bit (rx goes low)
                    if (!rx) begin
                        state <= START;
                        counter <= 0;
                    end
                end

                START: begin
                    // Wait for half a bit period to confirm the start bit
                    if (counter == SAMPLE_POINT) begin
                        if (!rx) begin
                            // Valid start bit detected
                            state <= SAMPLING;
                            counter <= 0;
                            data_counter <= 0;
                        end else begin
                            // False start bit we have to return to the idle state
                            state <= IDLE;
                        end
                    end else begin
                        counter <= counter + 1;
                    end
                end

                SAMPLING: begin
                    // Sample the data bits at the middle of each bit period
                    if (counter == SAMPLE_POINT) begin
                        data_reg <= {data_reg[6:0], rx}; // Shift and store the sampled bit
                    end
                    if (counter == COUNTER_LIMIT) begin
                        counter <= 0;
                        if (data_counter == 3'd7) begin
                            // All 8 data bits received
                            state <= STOP;
                        end else begin
                            // Move to the next bit
                            data_counter <= data_counter + 1;
                        end
                    end else begin
                        counter <= counter + 1;
                    end
                end

                STOP: begin
                    // Wait for the stop bit
                    if (counter == COUNTER_LIMIT) begin
                        data_out <= data_reg; // Output the received data
                        state <= IDLE;
                        counter <= 0;
                    end else begin
                        counter <= counter + 1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule