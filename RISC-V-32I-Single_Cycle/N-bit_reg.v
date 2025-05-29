`timescale 1ns / 1ps

module N_bit_reg#(parameter n = 32)(input clk, input rst, input load, input [n-1 : 0] D, output [n-1 : 0] Q 
    );
    wire [n-1:0] m_out;
    genvar i;
    
    generate 
    for (i = 0; i < n; i = i + 1) begin
    mux m(Q[i], D[i], load, m_out[i]);
    DFlipFlop DFF(clk,rst,m_out[i], Q[i]);
    end
    endgenerate
endmodule
