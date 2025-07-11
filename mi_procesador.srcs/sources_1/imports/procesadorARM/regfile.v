module regfile(
    input wire we3,
    input wire we4,
    input wire [3:0] a1,
    input wire [3:0] a2,
    input wire [3:0] wa3,
    input wire [31:0] wd3,
    input wire [31:0] r15,
    input wire [3:0] wa4, //nueva direccion input
    input wire [31:0] wd4, //nueva entrada de data
    output wire [31:0] rd1,
    output wire [31:0]rd2,
    input clk
    );
	
	reg [31:0] rf [14:0];
	always @(posedge clk)begin
		if (we3)
			rf[wa3] <= wd3;
		if (we4)
		  rf[wa4] <= wd4;
	end				
	assign rd1 = (a1 == 4'b1111 ? r15 : rf[a1]);
	assign rd2 = (a2 == 4'b1111 ? r15 : rf[a2]);
endmodule