`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.07.2025 12:02:30
// Design Name: 
// Module Name: fp_alu
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


module fp_alu(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] ALUControl,
    output wire [31:0] result_fp,
    output reg  [31:0] Result,
    output wire [3:0]  ALUFlags,
    input wire [31:0] Instr
    );

    wire neg, zero, carry, overflow;
    wire [31:0] condinvb;
    wire [32:0] sum;
    wire [31:0] fp_add_result;
    wire [31:0] fp_mul_result;
    wire [31:0] a_fp, b_fp;

    // Conversión automática de entero (two's complement) a float
    int_to_fp convert_a (.int_val(a), .fp_val(a_fp));
    int_to_fp convert_b (.int_val(b), .fp_val(b_fp));

    // Módulos de operaciones en punto flotante
    fp_add fp_adder (
        .a(a_fp),
        .b(b_fp),
        .result(fp_add_result)
    );

    fp_mul fp_multiplier (
        .a(a_fp),
        .b(b_fp),
        .result(fp_mul_result)
    );

    assign condinvb = ALUControl[0] ? ~b : b;
    assign sum = a + condinvb + ALUControl[0];

    always @(*) begin
        case (ALUControl)
            4'b1010: Result = fp_mul_result;
            4'B1011: Result = fp_add_result; // suma FP
            default: Result = 32'b0;
        endcase
    end

    assign result_fp = Result;

    // Flags solo válidos para operaciones enteras
    wire is_arith = (ALUControl == 4'b0000 || ALUControl == 4'b0001);
    assign neg      = result_fp[31];
    assign zero     = (result_fp[31:0] == 32'b0);
    assign carry    = is_arith & sum[32];
    assign overflow = is_arith & ~(a[31] ^ b[31] ^ ALUControl[0]) & (a[31] ^ sum[31]);

    assign ALUFlags = {neg, zero, carry, overflow};

endmodule


