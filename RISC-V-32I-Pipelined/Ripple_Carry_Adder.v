`timescale 1ns / 1ps

module Ripple_Carry_Adder#(n = 32)(
    input [n-1:0] a,
    input [n-1:0] b,
    input cin,
    output [n:0] sum
    );
    genvar i;
    wire [n:0] internal_carry;
    assign internal_carry[0] = cin;
    
    generate
    for( i = 0; i < n; i = i + 1) begin
        Full_Adder FA(a[i], b[i], internal_carry[i],sum[i],internal_carry[i+1]);
    end
    endgenerate
    assign sum[n] = internal_carry[n];
endmodule
