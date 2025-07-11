`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.07.2025 00:23:44
// Design Name: 
// Module Name: fp_add
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


// Módulo de suma de punto flotante en Verilog puro (IEEE-754, 32 bits)
// Simplificado: no considera NaN, Inf, denormales ni redondeo completo

module fp_add (
    input  wire [31:0] a,
    input  wire [31:0] b,
    output reg  [31:0] result
);
    // Descomposición
    wire sign_a = a[31];
    wire sign_b = b[31];
    wire [7:0] exp_a = a[30:23];
    wire [7:0] exp_b = b[30:23];
    wire [23:0] frac_a = {1'b1, a[22:0]};
    wire [23:0] frac_b = {1'b1, b[22:0]};

    reg [24:0] aligned_frac_a, aligned_frac_b;
    reg [7:0] exp_diff, exp_result;
    reg [24:0] frac_sum;
    reg sign_result;

    always @(*) begin
        if (exp_a > exp_b) begin
            exp_diff = exp_a - exp_b;
            aligned_frac_a = frac_a;
            aligned_frac_b = frac_b >> exp_diff;
            exp_result = exp_a;
        end else begin
            exp_diff = exp_b - exp_a;
            aligned_frac_a = frac_a >> exp_diff;
            aligned_frac_b = frac_b;
            exp_result = exp_b;
        end

        // Solo suma si mismo signo (resta no implementada aquí)
        if (sign_a == sign_b) begin
            frac_sum = aligned_frac_a + aligned_frac_b;
            sign_result = sign_a;

            if (frac_sum[24]) begin
                // Normalizar si hay carry
                frac_sum = frac_sum >> 1;
                exp_result = exp_result + 1;
            end

            result = {sign_result, exp_result, frac_sum[22:0]};
        end else begin
            // Simplificación: si los signos son distintos, se devuelve cero
            result = 32'b0;
        end
    end
endmodule