module fir_filter_tb;
    localparam W_X = 4,       // Input data width
               W_K = 4,       // Coefficient width
               N = 3,         // Number of taps
               W_Y = W_X + W_K + $clog2(N);  // Output data width

    `timescale 1ns/1ps;

    localparam logic signed [W_K-1:0] K [N+1] = {1, 2, 3, 4};  // Coefficients
    logic clk = 0, rstn = 0;
    localparam CLK_PERIOD = 10;  // Clock period

    // Generate a clock signal
    initial forever #(CLK_PERIOD/2) clk <= ~clk;

    logic signed [W_X-1:0] x = 0;  // Input data
    logic signed [W_Y-1:0] y;      // Output data

    fir_filter #(.N(N), .W_X(W_X), .W_K(W_K), .K(K)) dut (.clk(clk), .rstn(rstn), .x(x), .y(y));

    logic signed [W_X-1:0] zi [N+1] = '{default:0};  // Initialize delay line
    logic signed [W_X-1:0] zq [$] = zi;

    int status, y_exp = 0;
    int file_x = $fopen("D:/x.txt", "r");  // Open input file
    int file_y = $fopen("D:/y.txt", "w");  // Open output file

    // Drive signals
    initial begin
        $dumpfile("dump.vcd"); $dumpvars(0, dut);  // Dump waveform to VCD file
        #10 rstn <= 1;  // Release reset after 10 time units

        while (!$feof(file_x))
            @(posedge clk) #1 status = $fscanf(file_x, "%d\r", x);  // Read input data from file

        $fclose(file_x);  // Close input file

        repeat (N+1) @(posedge clk);  // Wait for filter operation to complete

        $fclose(file_y);  // Close output file
        $finish();  // Finish simulation
    end

    // Monitor signals
    initial forever begin
        @(posedge clk) #2;

        zq = {x, zq};  // Shift input data into delay line
        zq = zq[0:$-1];

        y_exp = 0;
        foreach (zq[i]) 
            y_exp += zq[i] * K[i];  // Calculate expected output

        // Check if actual output matches expected output
        assert (y == y_exp) begin
            $display("OK: y:%d", y);  // Display "OK" if they match
            $fdisplay(file_y, "%d", y);  // Write output data to file
        end else begin
            $display("Error: y:%d != y_exp:%d", y, y_exp);  // Display error if they don't match
        end
    end
endmodule
