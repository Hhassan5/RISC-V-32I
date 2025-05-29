`timescale 1ns / 1ps

module HazardUnit(
    input [4:0] IF_ID_RS1,
    input [4:0] IF_ID_RS2,
    input [4:0] ID_EX_RD,
    input ID_EX_MemRead,
    output reg stall
);

    always @(*) begin
        // Default: No stall
        stall = 1'b0;
        
        // Check for load-use hazard
        if (ID_EX_MemRead && ID_EX_RD != 0 && 
            ((IF_ID_RS1 == ID_EX_RD) || (IF_ID_RS2 == ID_EX_RD))) begin
            stall = 1'b1;
        end
    end
    
endmodule