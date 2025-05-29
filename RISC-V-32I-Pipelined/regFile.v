`timescale 1ns / 1ps

module regFile#(parameter n=32)(
    input clk,
    input rst,
    input RegWrite,
    input [4:0] rr1,
    input [4:0] rr2,
    input [4:0] wr,
    input [n-1:0] wd,
    output [n-1:0] rd1,
    output [n-1:0] rd2
    );
    
    // Register file array
    reg [n-1:0] RegFile [n-1:0];
    
    // Read operations (combinational)
    assign rd1 = RegFile[rr1];
    assign rd2 = RegFile[rr2];
    
    integer i;
    
    // Write operation (sequential)
    always@(negedge clk or posedge rst)
    begin
        if (rst)
        begin
            for(i=0; i<32; i = i+1) 
                RegFile[i] = 0;
        end
        else if (RegWrite && wr != 0)
            RegFile[wr] = wd;
        end
        
            
    
endmodule
