`timescale 1ns / 1ps


module DataMem #(n=32)(input clk, input MemRead, input MemWrite,
input [5:0] addr, input [n-1:0] data_in, output [n-1:0] data_out);

reg [n-1:0] mem [0:127];


//synchronous
always @(posedge clk) begin
    if (MemWrite) begin
        mem[addr] <= data_in;
    end
end

//asynchronous
assign data_out = MemRead ? mem[addr]:0;


initial begin
mem[0]=32'd17;
mem[1]=32'd9; 
mem[2]=32'd25; 
end

    
endmodule
