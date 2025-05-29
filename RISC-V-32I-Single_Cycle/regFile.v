`timescale 1ns / 1ps

module regFile#(n=32)(
    input clk,
    input rst,
    input reg_write,
    input [4:0] rr1,
    input [4:0] rr2,
    input [4:0] wr,
    input [n-1:0] wd,
    output [n-1:0] rd1,
    output [n-1:0] rd2
    );
    
    genvar i;
    wire [n-1:0] outData[n-1:0];
    reg [n-1:0] load;
    
    
    generate
    for (i = 0; i<n; i=i+1) begin
    N_bit_reg RF(.clk(clk),.rst(rst),.load(load[i]),.D(wd),.Q(outData[i]));
    end
    endgenerate
    
    always@(*)begin
    if(reg_write == 1'b1 && wr != 0)begin
        load = 32'b0;
        load[wr] = 1'b1;
    end
    else
        load = 32'b0;
    end
    
    assign rd1 = outData[rr1];
    assign rd2 = outData[rr2];     
endmodule
