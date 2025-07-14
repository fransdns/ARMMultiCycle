`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.07.2025 23:55:52
// Design Name: 
// Module Name: flags_selector
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


module flags_selector(
flags_fp,
flags_muls,
flags_alu,
ALUFlags,
Instr
    );
input wire[31:0] Instr;     
input wire[3:0] flags_fp; 
input wire[3:0] flags_alu; 
input wire[3:0] flags_muls; 
input wire[3:0] ALUFlags;

reg[3:0] flags_result;

wire S = Instr[20];  // bit S que indica si se deben setear flags

    
always @(*)begin 
if(Instr[27:26] == 2'b11)
    flags_result = flags_muls;
else if(Instr[24:21] == 4'b1110 || Instr[24:21] == 4'b1011) //Instr[27:26] == 2'b01 &&
    flags_result = flags_fp;    
else 
    flags_result = flags_alu;

end
//cuando asigno mis flags usando esas condicionales, realmente son las correctas ? 
//ahorita estoy analizando la instrucción CMP. Esa en cuál de las 3 entra ? 

assign ALUFlags = S ?  flags_result :  4'b0000 ;
    
endmodule
