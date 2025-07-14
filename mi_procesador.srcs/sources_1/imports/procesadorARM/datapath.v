module datapath (
	clk,
	reset,
	Adr,
	WriteData,
	ReadData,
	Instr,
	ALUFlags,
	PCWrite,
	RegWrite,
	IRWrite,
	AdrSrc,
	RegSrc,
	ALUSrcA,
	ALUSrcB,
	ResultSrc,
	ImmSrc,
	ALUControl,
	IsSignedMult,
	MuxResult,
	RegW2,
	mult_lo,
	mult_hi,
	mult_hi_ff,
	mult_lo_ff,
	result_fp,
	result_fp_ff
);
	input wire clk;
	input wire reset;
	output wire [31:0] Adr;
	output wire [31:0] WriteData;
	input wire [31:0] ReadData;
	output wire [31:0] Instr;
	output wire [3:0] ALUFlags;
	input wire PCWrite;
	input wire RegWrite;
	input wire IRWrite;
	input wire AdrSrc;
	input wire [1:0] RegSrc;
	input wire ALUSrcA;
	input wire [1:0] ALUSrcB;
	input wire [2:0] ResultSrc;
	input wire [1:0] ImmSrc;
	input wire [3:0] ALUControl; //ALUControl modificado a 4 bits
	wire [31:0] PCNext;
	wire [31:0] PC;
	wire [31:0] ExtImm;
	wire [31:0] SrcA;
	wire [31:0] SrcB;
	wire [31:0] Result;
	wire [31:0] Data;
	wire [31:0] RD1;
	wire [31:0] RD2;
	wire [31:0] A;
	wire [31:0] ALUResult;
	wire [31:0] ALUOut;
	wire [3:0] RA1;
	wire [3:0] RA2;
	output wire [63:0] result_fp; //resultado de punto flotante
	output wire [63:0] result_fp_ff;
	//nuevos
	output wire [31:0] MuxResult;
	input wire RegW2;
	output wire IsSignedMult;
	output wire[31:0] mult_lo;
	output wire[31:0] mult_hi;
	output wire[31:0] mult_lo_ff;
	output wire[31:0] mult_hi_ff;
	

     wire[3:0] flags_alu;
     wire[3:0] flags_fp;
     wire[3:0] flags_muls; 
	
	alu mi_alu(
	.a(SrcA),
	.b(SrcB),
	.ALUControl(ALUControl),
	.Result(ALUResult),
	.ALUFlags(flags_alu)
	);
	
	flags_selector mi_flags_selector(
	.flags_alu(flags_alu),
	.flags_fp(flags_fp),
	.flags_muls(flags_muls),
	.ALUFlags(ALUFlags),
	.Instr(Instr)
	);
	
	mult64 mi_mult64 (
    .a(A),
    .b(WriteData),
    .signo(Instr[24]),
    .res_lo(mult_lo), //debo de pasar esto a un FF
    .res_hi(mult_hi),  //debo de pasar esto a un FF
    .ALUFlags(flags_muls)
	);
	
	fp_alu mi_fp_alu(
	.a(A),
    .b(WriteData),
    .ALUControl(ALUControl),
    .result_fp(result_fp),
    .Instr(Instr),
    .ALUFlags(flags_fp)
	);
	
	flopr #(64) mi_ff_fp_alu(
	.reset(reset),
	.clk(clk),
	.d(result_fp),
	.q(result_fp_ff)
	);
	
	//creación de 2 flip flops para la saluda de mult64 module
	flopr #(32) mi_ff_mult_lo(
	.reset(reset),
	.d(mult_lo),
	.clk(clk),
	.q(mult_lo_ff)
	);
	
	flopr #(32) mi_ff_mult_hi(
	.reset(reset),
	.d(mult_hi),
	.clk(clk),
	.q(mult_hi_ff)
	);

	
	extend mi_extend(
	.Instr(Instr[23:0]),
	.ImmSrc(ImmSrc),
	.ExtImm(ExtImm)
	);
	
	//flipflops
	flopenr #(32) mi_ff_pc(
	.reset(reset),
	.en(PCWrite),
	.d(Result),
	.clk(clk),
	.q(PC)
	);
	
	flopenr #(32) mi_ff_instr(
	.reset(reset),
	.en(IRWrite),
	.d(ReadData),
	.clk(clk),
	.q(Instr)
	);
	
	flopr #(32) mi_ff_data(
	.reset(reset),
	.d(ReadData),
	.clk(clk),
	.q(Data)
	);
	
	flopr #(32) mi_ff_rd1(
	.reset(reset),
	.clk(clk),
	.d(RD1),
	.q(A)
	);
	
	flopr #(32) mi_ff_rd2(
	.reset(reset),
	.clk(clk),
	.d(RD2),
	.q(WriteData)
	);
	
	flopr #(32) mi_ff_aluout(
	.reset(reset),
	.d(ALUResult),
	.clk(clk),
	.q(ALUOut)
	);
	
	
	//mux de 3
	mux3 #(32) mi_mux3_srcB(
	.s(ALUSrcB),
	.d0(WriteData),
	.d1(ExtImm),
	.d2(32'b100),
	.y(SrcB)
	);
	
	mux5 #(32) mi_mux5_result(
	.s(ResultSrc),
	.d0(ALUOut),
	.d1(Data),
	.d2(ALUResult),
	.d3(mult_lo_ff),
	.d4(result_fp_ff),
	.y(Result)
	);
	
	
	
	//muxs de 2
	mux2 #(32) mi_mux2_adr(
	.s(AdrSrc),
	.d0(PC),
	.d1(Result),
	.y(Adr)
	);
	mux2 #(32) mi2_mux2_ra1(
	.s(RegSrc[0]),
	.d0(Instr[19:16]),
	.d1(Instr[15]),
	.y(RA1)
	);
	mux2 #(32) mi3_mux2_ra2(
	.s(RegSrc[1]),
	.d0(Instr[3:0]),
	.d1(Instr[15:12]),
	.y(RA2)
	);
	mux2 #(32) mi2_mux2_srcA(
	.s(ALUSrcA),
	.d1(PC),
	.d0(A),
	.y(SrcA)
	);
	
	regfile mi_regfile(
	.a1(RA1),
	.a2(RA2),
	.wa3(Instr[15:12]),
	.wd3(Result),
	.r15(Result),
	.rd1(RD1),
	.rd2(RD2),
	.clk(clk),
	.we3(RegWrite),
	.we4(RegW2), //esto es necesario, pero causa conflictos.
	.wa4(Instr[11:8]),//  RdHi a wa4
	.wd4(mult_hi_ff)
	);
	
	
endmodule

