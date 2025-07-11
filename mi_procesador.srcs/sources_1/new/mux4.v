`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.07.2025 17:14:20
// Design Name: 
// Module Name: mux4
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


module mux5(
	d0,
	d1,
	d2,
	d3,
	d4,
	s,
	y
);
	parameter WIDTH = 8;
	input wire [WIDTH - 1:0] d0;
	input wire [WIDTH - 1:0] d1;
	input wire [WIDTH - 1:0] d2;
	input wire [WIDTH - 1:0] d3;
	input wire [WIDTH - 1:0] d4;
	input wire [2:0] s;
	output wire [WIDTH - 1:0] y;

	assign y = (s == 3'b000) ? d0 :
	           (s == 3'b001) ? d1 :
	           (s == 3'b010) ? d2 :
	           (s == 3'b011) ? d3:
	               d4;
endmodule
