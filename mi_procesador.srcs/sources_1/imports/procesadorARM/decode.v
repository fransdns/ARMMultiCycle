module decode (
	clk,
	reset,
	Op,
	Funct,
	Rd,
	FlagW,
	PCS,
	NextPC,
	RegW,
	MemW,
	IRWrite,
	AdrSrc,
	ResultSrc,
	ALUSrcA,
	ALUSrcB,
	ImmSrc,
	RegSrc,
	ALUControl,
	RegW2,
	Instr,
	opcode
);
	input wire clk;
	input wire reset;
	input wire [1:0] Op;
	
	input wire [3:0] opcode;
    //declaracion de instrucciones
    input wire [31:0] Instr;
	input wire [5:0] Funct;
	input wire [3:0] Rd;
	output reg [1:0] FlagW;
	output wire PCS;
	output wire NextPC;
	output wire RegW;
	output wire MemW;
	output wire IRWrite;
	output wire AdrSrc;
	output wire [2:0] ResultSrc;
	output wire  ALUSrcA;
	output wire [1:0] ALUSrcB;
	
	output reg [1:0] ImmSrc;
	output wire [1:0] RegSrc;
	output reg [3:0] ALUControl;
	wire Branch;
	wire ALUOp;
	
	output wire RegW2;

	// Main FSM
	mainfsm fsm(
		.clk(clk),
		.reset(reset),
		.Op(Op),
		.Funct(Funct),
		.IRWrite(IRWrite),
		.AdrSrc(AdrSrc),
		.ALUSrcA(ALUSrcA),
		.ALUSrcB(ALUSrcB),
		.ResultSrc(ResultSrc),
		.NextPC(NextPC),
		.RegW(RegW),
		.MemW(MemW),
		.Branch(Branch),
		.ALUOp(ALUOp),
		.RegW2(RegW2),
		.opcode(opcode)
	);


	 always @(*) begin
        if (ALUOp) begin
        $display("Funct: %b, ALUControl: %b", Funct, ALUControl);
            case (Funct[4:1])
                4'b0100: ALUControl = 4'b0000; // Suma
                4'b0010: ALUControl = 4'b0001; // Resta
                4'b0000: ALUControl = 4'b0010; // AND
                4'b1100: ALUControl = 4'b0011; // OR
                4'b0001: ALUControl = 4'b0100; // XOR
                4'b1101: ALUControl = 4'b0101; // MOV
                4'b1001: ALUControl = 4'b0110; // MUL
                4'b1110: ALUControl = 4'b0111; //Div
                4'b1111: ALUControl = 4'b1111; //MVN
                default: ALUControl = 4'bxxxx;
                
            endcase
            FlagW[1] = Funct[0];
            FlagW[0] = Funct[0] & ((ALUControl == 3'b000) | (ALUControl == 3'b001));
        end
        else begin
            ALUControl = 3'b000;
            FlagW = 2'b00;
        end
    end
	// PC Logic
    assign PCS = ((Rd == 4'b1111) & RegW) | Branch;

	assign RegSrc[0] = (Op == 2'B10)? 1 : 0;
	assign RegSrc[1] = (Op == 2'B01)? 1 : 0;
	 
    always @(*) begin
    if (Instr[27:26] == 2'b00 && Instr[25] == 1)
        ImmSrc = 2'b11;
    else
        ImmSrc = Op;
end

    
endmodule
	