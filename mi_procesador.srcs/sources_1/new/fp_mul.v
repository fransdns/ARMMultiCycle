`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.07.2025 00:26:49
// Design Name: 
// Module Name: fp_mul
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// Multiplicación punto flotante en Verilog puro
module fp_mul (
    input wire [31:0] a,
    input wire [31:0] b,
    output reg [31:0] result
);
    wire sign_a = a[31];
    wire sign_b = b[31];
    wire [7:0] exp_a = a[30:23];
    wire [7:0] exp_b = b[30:23];
    wire [23:0] frac_a = {1'b1, a[22:0]};
    wire [23:0] frac_b = {1'b1, b[22:0]};

    wire sign_result = sign_a ^ sign_b;
    reg [47:0] frac_mult;
    reg [7:0] exp_result;

    always @(*) begin
        frac_mult = frac_a * frac_b; // 24 x 24 = 48 bits
        exp_result = exp_a + exp_b - 127; // Bias

        // Normalización
        if (frac_mult[47]) begin
            frac_mult = frac_mult >> 1;
            exp_result = exp_result + 1;
        end

        result = {sign_result, exp_result, frac_mult[45:23]};
    end
endmodule