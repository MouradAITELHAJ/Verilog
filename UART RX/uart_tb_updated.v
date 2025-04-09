`timescale 1ns / 1ps

module uart_rx_tb;

    // Inputs
    reg clk;
    reg reset;
    reg rx;

    // Outputs
    wire [7:0] data_out;
    reg data_valid; // Used only in simulation

    // Instantiate the UART receiver
    uart_rx uut (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(data_out)
    );

    reg [7:0] data = 8'b10101010; // Test data

    // Clock generation (27 MHz clock)
    initial begin
        clk = 0;
        forever #18.519 clk = ~clk; // 37.037 ns period (27 MHz)
    end

    // Test sequence
    initial begin
        reset = 0;
        rx = 1;       // Idle state
        data_valid = 0;

        // Apply reset (2 clock cycles = 74.074 ns)
        #74.074;     // Explicit ns unit
        reset = 1;
        #74.074;

        // Send data (9600 baud = 104.167 µs per bit)
        rx = 0;       // Start bit
        #104167;     // 104.167 µs (exact bit duration)

        // Data bits (LSB first)
        rx = 1; #104167; // Bit 0
        rx = 0; #104167; // Bit 1
        rx = 1; #104167; // Bit 2
        rx = 0; #104167; // Bit 3
        rx = 1; #104167; // Bit 4
        rx = 0; #104167; // Bit 5
        rx = 1; #104167; // Bit 6
        rx = 0; #104167; // Bit 7

        // Stop bit
        rx = 1; #104167;

        // Wait 1.5 bit durations to ensure UART completes
        #156250;      // 104.167 µs * 1.5 = 156.250 µs (safety margin)

        // Verify received data
        if (data_out === data) begin
            data_valid = 1;
            $display("Test passed: data_out = %b", data_out);
        end else begin
            $display("Test failed: data_out = %b, expected = %b", data_out, data);
        end

        $finish;
    end

    // Generate VCD dump for debugging
    initial begin
        $dumpfile("uart_rx_tb.vcd");
        $dumpvars(0, uart_rx_tb);
    end

endmodule