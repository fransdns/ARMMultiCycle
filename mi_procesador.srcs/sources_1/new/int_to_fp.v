`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.07.2025 00:49:37
// Design Name: 
// Module Name: int_to_fp
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


// Conversión de entero con signo (complemento a dos) a punto flotante IEEE-754
module int_to_fp (
    input  wire [31:0] int_val,
    output reg  [31:0] fp_val
);
    reg sign;
    reg [31:0] abs_val;
    reg [7:0] exponent;
    reg [23:0] mantissa;
    integer i;
    reg found;

    always @(*) begin
        if (int_val == 32'b0) begin
            fp_val = 32'b0;
        end else begin
            // Obtener signo y valor absoluto
            sign = int_val[31];
            abs_val = sign ? (~int_val + 1) : int_val;

            found = 0;
            exponent = 0;
            mantissa = 0;

            // Buscar la primera '1' desde MSB para normalizar
            for (i = 31; i >= 0; i = i - 1) begin
                if (!found && abs_val[i]) begin
                    exponent = i + 127;
                    mantissa = abs_val << (23 - i);
                    found = 1;
                end
            end

            fp_val = {sign, exponent, mantissa[22:0]};
        end
    end
endmodule
