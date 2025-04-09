`timescale 1ns / 1ps

module uart_rx_tb;

    // Inputs
    reg clk;
    reg reset;
    reg rx;

    // Outputs
    wire [7:0] data_out;

    reg data_valid; //used just in sim

    // Instantiate the uart_rx
    uart_rx uut (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(data_out)
    );

    reg [7:0] data = 8'b10101010; // only for simulation

    // Clock generation (27 MHz clock)
    initial begin
        clk = 0;
        forever #18.519 clk = ~clk; // 37.037 ns period (27 MHz)
    end

   
    initial begin
        reset = 0;
        rx = 1;
        data_valid = 0;
        #74074; 
        reset = 1;
        #74074;

        // Send data (9600 baud rate => 104167 ns per bit)

        rx = 0; // Start bit
        #104167;

       
        rx = 1; #104167; 
        rx = 0; #104167; 
        rx = 1; #104167; 
        rx = 0; #104167; 
        rx = 1; #104167; 
        rx = 0; #104167; 
        rx = 1; #104167; 
        rx = 0; #104167; 

        
        rx = 1; #104167;// Stop bit

        // Wait for the data to be received
        #104167; 

        // Verify 
        if (data_out === data) begin
            data_valid = 1; // Assert data_valid for simulation
            $display("Test passed: data_out = %b", data_out);
        end else begin
            $display("Test failed: data_out = %b, expected = %b", data_out, data);
        end

        $finish;
    end

endmodule