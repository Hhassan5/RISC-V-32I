`timescale 1ns / 1ps

module forwardingUnit(input [4:0] ID_EX_RS1,
    input [4:0] ID_EX_RS2,
    input [4:0] EX_MEM_Rd,
    input [4:0] MEM_WB_Rd,
    input EX_MEM_RegWrite,
    input MEM_WB_RegWrite,
    output reg [1:0] forwardA,
    output reg [1:0] forwardB
);

    always @(*) begin
        // Default: No forwarding
        forwardA = 2'b00;
        forwardB = 2'b00;
        
        // EX Hazard - Forward from EX/MEM pipeline register
        if (EX_MEM_RegWrite && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_RS1))
            forwardA = 2'b10;
            
        if (EX_MEM_RegWrite && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_RS2))
            forwardB = 2'b10;
            
        // MEM Hazard - Forward from MEM/WB pipeline register
        if (MEM_WB_RegWrite && (MEM_WB_Rd != 0) && (MEM_WB_Rd == ID_EX_RS1) &&
           !(EX_MEM_RegWrite && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_RS1)))
            forwardA = 2'b01;
            
        if (MEM_WB_RegWrite && (MEM_WB_Rd != 0) && (MEM_WB_Rd == ID_EX_RS2) &&
           !(EX_MEM_RegWrite && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_RS2)))
            forwardB = 2'b01;
    end
    
endmodule
