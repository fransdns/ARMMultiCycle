module alu(a, b, ALUControl, Result, ALUFlags);
    input  [31:0] a, b;
    input  [3:0]  ALUControl;
    output reg [31:0] Result;
    output wire [3:0]  ALUFlags;
    
    wire  neg, zero, carry, overflow;
    wire [31:0] condinvb;
    wire [32:0] sum;
    assign condinvb = ALUControl[0] ? ~b : b;
    assign sum = a + condinvb + ALUControl[0];
    always @(*)
    begin
        casex (ALUControl[3:0])
        //se aumentó a 3 bits para soportar más funciones
            4'b0000: Result = sum;
            4'b0001: Result = sum;
            4'b0010: Result = a & b;
            4'b0011: Result = a | b;
            4'b0100: Result = a ^ b; 
            4'b0110: Result = a * b; // para MUL
            4'b0101: Result = b; //mov
            4'b0111: Result = a/b; //div
            4'b1111: Result = ~b; //MVN
        endcase
    end
    assign neg      = Result[31];
    assign zero     = (Result == 32'b0);
    assign carry    = (ALUControl[3:1] == 2'b00) & sum[32];
    assign overflow = (ALUControl[3:1] == 2'b00) & ~(a[31] ^ b[31] ^ ALUControl[0]) & (a[31] ^ sum[31]);
    assign ALUFlags = {neg, zero, carry, overflow};
endmodule