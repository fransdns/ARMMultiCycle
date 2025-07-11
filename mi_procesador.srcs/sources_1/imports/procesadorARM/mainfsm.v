module mainfsm (
	clk,
	reset,
	Op,
	Funct,
	IRWrite,
	AdrSrc,
	ALUSrcA,
	ALUSrcB,
	ResultSrc,
	NextPC,
	RegW,
	MemW,
	Branch,
	ALUOp,
	IsSignedMult,
	RegW2,
	opcode
);
	input wire clk;
	input wire reset;
	input wire [1:0] Op;
	input wire [5:0] Funct;
	input wire [3:0] opcode;
	output wire IRWrite;
	output wire AdrSrc;
	output wire  ALUSrcA;
	output wire [1:0] ALUSrcB;
	output wire [2:0] ResultSrc;
	output wire NextPC;
	output wire RegW;
	output wire MemW;
	output wire Branch;
	output wire ALUOp;
	
	output wire IsSignedMult; // señal para ver si la operacion MUL es S o U
	output wire RegW2;  // mi otra señal de control para wd4,wa4
	
	
	reg [4:0] state;
	reg [4:0] nextstate;
	reg [14:0] controls; //aumentamos 3 bits de control
	
	localparam [4:0] FETCH = 0;
	localparam [4:0] BRANCH = 9;
	localparam [4:0] DECODE = 1;
	localparam [4:0] EXECUTEI = 7;
	localparam [4:0] EXECUTER = 6;
	localparam [4:0] MEMADR = 2;
	localparam [4:0] UNKNOWN = 10;
	localparam [4:0] ALUWB = 8;
	localparam [4:0] MEMWR = 5;
	localparam [4:0] MEMRD = 3;
	localparam [4:0] MEMWB= 4;
			
    //nuevos estados para SMULL/UMULL
	localparam [4:0] EXECUTE_MUL  = 11;
	localparam [4:0] MULWB = 12;
	localparam [4:0] MULWB2 = 13;
	localparam [4:0] MULWB3 = 14;
	localparam [4:0] EXECUTE_SMUL  = 15;
	
	//NUEVOS ESTADOS PARA FLOATING POINT
	localparam  [4:0] EXECUTE_FP = 16;
	localparam  [4:0] FP_WB = 17 ;
	localparam  [4:0] FP_WB2 = 18;

	// state register
	always @(posedge clk or posedge reset)
		if (reset)
			state <= FETCH;
		else
			state <= nextstate;
	


  	// next state logic
	always @(*)
		casex (state)
			FETCH: nextstate = DECODE;
			DECODE:
				case (Op)
					2'b00:
						if (Funct[5])
							nextstate = EXECUTEI;
						else if(opcode == 4'b1111)
						  nextstate = EXECUTE_FP;	
						else
							nextstate = EXECUTER;
					2'b01: nextstate = MEMADR;
					2'b10: nextstate = BRANCH;
					2'b11: nextstate = EXECUTE_MUL; // op = 11 para ir a otro EXECUTE_MUL
					default: nextstate = UNKNOWN;
				endcase
			EXECUTER: nextstate = ALUWB;
			EXECUTE_MUL: nextstate = MULWB; //nuevo 
			

			EXECUTEI: nextstate = ALUWB;
			MEMADR:
			     if(Funct[0])
			         nextstate = MEMRD;
			     else
			         nextstate = MEMWR; 
			MEMRD: nextstate = MEMWB; 
			BRANCH: nextstate = FETCH; 
			MULWB: nextstate = MULWB2;
			MULWB2: nextstate = MULWB3;
			
			EXECUTE_FP: nextstate = FP_WB;
			FP_WB: nextstate = FP_WB2;
			default: nextstate = FETCH;
		endcase


	// state-dependent output logic
	always @(*)
		case (state)			
/*{IsSignedMult-1, RegW2-1, NextPC-1, Branch-1, MemW-1, RegW-1, IRWrite-1, AdrSrc-1, ResultSrc-3, ALUSrcA-1, ALUSrcB-2, ALUOp-1*/
			FETCH: controls =       15'b0_0_1_0_0_0_1_0_010_1_100;
			DECODE: controls =      15'b0_0_0_0_0_0_0_0_010_1_100;
			EXECUTER: controls =    15'b0_0_0_0_0_0_0_0_000_0_001;
			EXECUTEI: controls =    15'b0_0_0_0_0_0_0_0_000_0_011;
			BRANCH: controls =      15'b0_0_0_1_0_0_0_0_010_0_010;
			MEMADR: controls =      15'b0_0_0_0_0_0_0_0_000_0_010;
			MEMRD: controls =       15'b0_0_0_0_0_0_0_1_000_0_000;
			MEMWR: controls =       15'b0_0_0_0_1_0_0_1_000_0_000;
			ALUWB: controls =       15'b0_0_0_0_0_1_0_0_000_0_000;
			MEMWB: controls =       15'b0_0_0_0_0_1_0_0_001_0_000;

            EXECUTE_MUL: controls = 15'b0_0_0_0_0_1_0_0_011_0_000;        // controles solo para UMUL. SMUL se verá después
			MULWB: controls =       15'b0_1_0_0_0_1_0_0_011_0_000;//     mi regW está en 1 en ambos.
			MULWB2: controls =      15'b0_1_0_0_0_1_0_0_011_0_000;
			MULWB3: controls =      15'b0_1_0_0_0_1_0_0_011_0_000;
			
			EXECUTE_FP: controls =  15'b0_0_0_0_0_0_0_0_111_0_001;
			FP_WB: controls =       15'b0_0_0_0_0_0_0_0_111_0_001;
			FP_WB2: controls =      15'b0_0_0_0_0_0_0_0_111_0_001;
			
			default: controls =     15'bxxxxxxxxxxxxx;
			
			/*
			assign y = (s == 3'b000) ? d0 :
	           (s == 3'b001) ? d1 :
	           (s == 3'b010) ? d2 :
	           (s == 3'b011) ? d3:
	               d4;
			*/
			//espacio para agregar un nuevo estado, que cambie los bits de ResultSrc 3 bits.
			//agregé un cero  a todos los controlels existentes actualmente. El selector par floating point
			//será solo el por defecto. 
			/*EXECUTE_FP: controls = 15'b00000000;
			FP_WB: controls = 15'b0000000;
			FP_WB2: controls = 15'b00000000;
			
			default: controls = 15'bxxxxxxxxxxxxx;*/
		endcase
	assign {IsSignedMult, RegW2, NextPC, Branch, MemW, RegW, IRWrite, AdrSrc, ResultSrc, ALUSrcA, ALUSrcB, ALUOp} = controls;
endmodule

