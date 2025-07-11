module extend (
	input wire [23:0] Instr,
	input wire [1:0] ImmSrc,
	output reg [31:0] ExtImm
);
	// función auxiliar para rotar a la derecha
	function [31:0] ror;
		input [31:0] value;
		input [4:0]  amount;  // solo se usan hasta 30 grados (2 * 15)
		begin
			ror = (value >> amount) | (value << (32 - amount));
		end
	endfunction

	wire [7:0] imm8 = Instr[7:0];
	wire [3:0] rotate_imm = Instr[11:8];
	wire [4:0] rotate_amount = {rotate_imm, 1'b0}; // 2 * rotate_imm

	always @(*) begin
		case (ImmSrc)
			2'b00: ExtImm = {24'b0, Instr[7:0]};          // tipo A
			2'b01: ExtImm = {20'b0, Instr[11:0]};         // tipo B
			2'b10: ExtImm = {{6{Instr[23]}}, Instr[23:0], 2'b00}; // tipo C
			2'b11: ExtImm = ror({24'b0, imm8}, rotate_amount); // inmediato rotado (nuevo caso)
			default: ExtImm = 32'bx;
		endcase
	end
endmodule
