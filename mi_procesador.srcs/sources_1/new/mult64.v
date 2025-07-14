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
    output wire [63:0] res_total,
    output wire [3:0]  ALUFlags
);

    // Extensión con o sin signo
    wire signed [63:0] a_signed_ext = {{32{a[31]}}, a};
    wire signed [63:0] b_signed_ext = {{32{b[31]}}, b};

    wire [63:0] a_unsigned_ext = {32'b0, a};
    wire [63:0] b_unsigned_ext = {32'b0, b};

    // Resultado de multiplicación signed o unsigned
    wire signed [63:0] result_signed = a_signed_ext * b_signed_ext;
    wire [63:0] result_unsigned = a_unsigned_ext * b_unsigned_ext;

    // Asignación final según el modo
    assign res_total = signo ? result_signed : result_unsigned;
    assign res_lo = res_total[31:0];
    assign res_hi = res_total[63:32];
    
    // Flags: N = bit más significativo de res_hi, Z = si res_total == 0
    wire N_flag = res_hi[31];
    wire Z_flag = (res_total == 64'b0);
    wire C_flag = 1'b0; // no definido en multiplicaciones
    wire V_flag = 1'b0; // no definido en multiplicaciones

    assign ALUFlags = {N_flag, Z_flag, C_flag, V_flag};

endmodule
