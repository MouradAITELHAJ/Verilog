`timescale 1ns/1ps

module uart_tx_tb;
    reg clk;
    reg reset;    
    reg tx_busy;
    reg [7:0] data_in;
    wire tx;
    wire done;
 
    // Instantiate UART transmitter
    uart_tx uut(
        .clk(clk),
        .reset(reset),
        .tx_busy(tx_busy),
        .data_in(data_in),
        .tx(tx),
        .done(done)
    );

    // Clock generation (50MHz)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

   initial begin
    
        reset = 0;
        tx_busy = 1;

        // Apply reset
        #20.0; 
        reset = 1;
        #20.0;

        
        tx_busy = 0; 
        #20000;
        data_in = 8'hA5;
         #1041667 
         tx_busy = 1;
    $finish; 
end

endmodule