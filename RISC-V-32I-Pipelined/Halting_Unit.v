`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2025 11:59:38 PM
// Design Name: 
// Module Name: Halting_Unit
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


module Halting_Unit(
    input [6:0] opcode,
    output reg halt
    );
    
    always @(*) begin
        if (opcode == 7'b0001111 || opcode == 7'b1110011) begin
            halt = 1;   
        end
        else begin
            halt = 0;
        end
    end
endmodule
