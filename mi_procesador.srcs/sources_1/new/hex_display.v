`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.07.2025 17:58:28
// Design Name: 
// Module Name: hex_display
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


module HexTo7Segment(
input [3:0] digit, 
output reg [7:0] catode
);
always @(*) begin
case (digit)
4'h0: catode = 8'b11000000;
4'h1: catode = 8'b11111001;
4'h2: catode = 8'b10100100;
4'h3: catode = 8'b10110000;
4'h4: catode = 8'b10011001;
4'h5: catode = 8'b10010010;
4'h6: catode = 8'b10000010;
4'h7: catode = 8'b11111000;
4'h8: catode = 8'b10000000;
4'h9: catode = 8'b10010000;
4'hA: catode = 8'b10001000;
4'hB: catode = 8'b10000011;
4'hC: catode = 8'b11000110;
4'hD: catode = 8'b10100001;
4'hE: catode = 8'b10000110;
4'hF: catode = 8'b10001110;
default: catode = 8'b11111111; //como la guía dice que opera con lógica negada
endcase
end
endmodule

module CLKdivider(input clk, input reset, output reg t);
reg [31:0] count;
always @(posedge clk or posedge reset) begin
if (reset) begin
count <= 0;
t <= 0;
end else if (count == 104_167) begin // el valor del count sale de 100M/480 = 280.333 y
count <= 0;
t <= ~t;
end else begin
count <= count +1;
end
end
endmodule

module hFSM(

input clk,
input reset,
input [15:0] data,
output reg [3:0] digit,
output reg [3:0] anode
);
reg [1:0] state;
always @(posedge clk or posedge reset) begin
if (reset)
state <= 2'b00;
else
state <= state + 1;
end
always @(*) begin
case (state)
2'b00: begin digit = data[15:12]; anode = 4'b1110; end
2'b01: begin digit = data[11:8]; anode = 4'b1101; end
2'b10: begin digit = data[7:4]; anode = 4'b1011; end
2'b11: begin digit = data[3:0]; anode = 4'b0111; end
endcase
end
endmodule

//Main module
module hex_display (
input clk,
input reset,
input [15:0] data,
output wire [3:0] anode,
output wire [7:0] catode
);
wire scl_clk;
wire [3:0] digit;
CLKdivider sc (.clk(clk), .reset(reset), .t(scl_clk));
hFSM m (.clk(scl_clk), .reset(reset), .data(data), .digit(digit), .anode(anode));
HexTo7Segment decoder (.digit(digit), .catode(catode));
endmodule

