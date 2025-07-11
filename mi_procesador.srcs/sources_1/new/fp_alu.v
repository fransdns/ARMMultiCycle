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
a,
b,
result_fp);

input wire [31:0] a;
input wire [31:0] b;
output wire [63:0] result_fp;

assign result_fp = a+b;


endmodule
