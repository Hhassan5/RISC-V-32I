`timescale 1ns / 1ps

module nbit_mux#(parameter n = 32)(input [n-1:0]a, input [n-1:0]b, input sel, output [n-1:0]out)
;
genvar i;
generate 
for( i =0; i<n;i=i+1)begin
mux mux_inst(a[i],b[i],sel,out[i]);
end
endgenerate 

endmodule