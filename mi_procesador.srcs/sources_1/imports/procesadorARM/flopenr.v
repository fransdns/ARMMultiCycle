module flopenr (
	clk,
	reset,
	en,
	d,
	q
);
	parameter WIDTH = 32;
	input wire clk;
	input wire reset;
	input wire en;
	input wire [WIDTH - 1:0] d;
	output reg [WIDTH - 1:0] q;
	always @(posedge clk or posedge reset)
		if (reset)
			q <= 0;
		else if (en)
			q <= d;
			
	initial begin 
	$monitor("sennal, desde ff pc a=%a",q);
	end		
endmodule