`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.07.2025 23:45:53
// Design Name: 
// Module Name: mult64
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

module mult64(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire signo, // 1: signed (SMULL), 0: unsigned (UMULL)
    output wire [31:0] res_lo,
    output wire [31:0] res_hi,
    output wire [63:0] res_total
);

    // Operandos extendidos a 64 bits con signo o sin signo
    wire signed [63:0] a_signed_ext = {{32{a[31]}}, a};
    wire signed [63:0] b_signed_ext = {{32{b[31]}}, b};

    wire [63:0] a_unsigned_ext = {32'b0, a};
    wire [63:0] b_unsigned_ext = {32'b0, b};

    // Resultado condicional según signo
    wire [63:0] result_total = signo ? (a_signed_ext * b_signed_ext) : (a_unsigned_ext * b_unsigned_ext);

    // Asignaciones finales
    assign res_total = result_total;
    assign res_lo = result_total[31:0];
    assign res_hi = result_total[63:32];

endmodule

