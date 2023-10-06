module fir_filter #(
    parameter N = 5,           // Number of taps
    parameter W_X = 8,         // Input data width
    parameter W_K = 3,         // Coefficient width
    parameter logic signed [W_K-1:0] K [N+1] = '{default:0},  // Coefficients
    localparam W_Y = W_X + W_K + $clog2(N)   // Output data width
)(
    input clk,                  // Clock signal
    input rstn,                 // Reset signal (active low)
    input logic signed [W_X-1:0] x,  // Input data
    output logic signed [W_Y-1:0] y  // Output data
);

    genvar n;
    logic signed [N:0][W_X-1:0] z;  // Delay line for input data, creating N+1 registers to store Xs.

    assign z[0] = x; // we are connecting x directly to the z[0] it is not register, it is combinational

    always_ff @(posedge clk or negedge rstn) begin
        z[N:1] <= ~rstn ? '0 : z[N-1:0];  // Shift data through the delay line // previous Z values are assigned to new value where Z[0] is new X
    end

    always_comb begin
        y = 0;
        for (int n = 0; n < N+1; n = n + 1) begin
            y = y + K[n] * $signed(z[n]);  // FIR filter operation
        end
    end
endmodule
