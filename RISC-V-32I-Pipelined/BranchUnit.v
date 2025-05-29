`timescale 1ns / 1ps

module BranchUnit(
    input carryFlag, zeroFlag, overflowFlag, signFlag,
    input [2:0] funct3,
    input [1:0] branchSignal,
    output reg [1:0] out
);

// Branch signal types
localparam [1:0] 
    BRANCH_NONE    = 2'b00,  // PC+4
    BRANCH_COND    = 2'b01,
    BRANCH_JAL     = 2'b10, 
    BRANCH_JALR    = 2'b11;

// Branch condition types (funct3 field)
localparam [2:0]
    BEQ  = 3'b000,
    BNE  = 3'b001,
    BLT  = 3'b100,
    BGE  = 3'b101,
    BLTU = 3'b110,
    BGEU = 3'b111;

// Output actions
localparam [1:0]
    PC_PLUS4  = 2'b00,  
    PC_BRANCH = 2'b01,  
    PC_JAL    = 2'b10,
    PC_JALR   = 2'b11; 

always @(*) begin
    case(branchSignal)
        BRANCH_COND: begin  // Conditional branch
            case(funct3)
                BEQ:  out = (zeroFlag == 1'b1) ? PC_BRANCH : PC_PLUS4;
                BNE:  out = (zeroFlag == 1'b0) ? PC_BRANCH : PC_PLUS4;
                BLT:  out = (signFlag != overflowFlag)  ? PC_BRANCH : PC_PLUS4;
                BGE:  out = (signFlag == overflowFlag)   ? PC_BRANCH : PC_PLUS4;
                BLTU: out = (carryFlag == 1'b0) ? PC_BRANCH : PC_PLUS4;
                BGEU: out = (carryFlag == 1'b1) ? PC_BRANCH : PC_PLUS4;
                default: out = PC_PLUS4;
            endcase
        end
        
        BRANCH_JALR: out = PC_JALR;
        BRANCH_JAL:  out = PC_JAL; 
        BRANCH_NONE: out = PC_PLUS4;
        default:     out = PC_PLUS4;
    endcase
end

endmodule