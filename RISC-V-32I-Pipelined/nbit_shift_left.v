`timescale 1ns / 1ps

module nbit_shift_left#(parameter n = 32)(input [n-1:0] in, output [n-1:0] out
    );
    
    assign out = {in[n-2:0], 1'b0};
    
endmodule
