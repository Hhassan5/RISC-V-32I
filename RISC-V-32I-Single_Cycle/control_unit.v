`timescale 1ns / 1ps

module control_unit(
    input [6:2] inst,
    output reg [1:0] Branch,
    output reg MemRead, 
    output reg [1:0] MemtoReg,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite,
    output reg [3:0] ALUOp 
);

localparam [4:0] 
    Branch_OP   = 5'b11000,
    Load_OP     = 5'b00000,
    Store_OP    = 5'b01000,
    JALR_OP     = 5'b11001,
    JAL_OP      = 5'b11011,
    Arith_I_OP  = 5'b00100,
    Arith_R_OP  = 5'b01100,
    AUIPC_OP    = 5'b00101,
    LUI_OP      = 5'b01101,
    SYSTEM_OP   = 5'b11100;

always @(*) begin
    case (inst)
        Arith_R_OP: begin
            Branch = 2'b00;
            MemRead = 1'b0;
            MemtoReg = 2'b00;
            ALUOp = 4'b0000;
            MemWrite = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b1;
        end

        Load_OP: begin
            Branch = 2'b00;
            MemRead = 1'b1;
            MemtoReg = 2'b01;
            ALUOp = 4'b0001;
            MemWrite = 1'b0;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
        end

        Store_OP: begin
            Branch = 2'b00;
            MemRead = 1'b0;
            MemtoReg = 2'b00;
            ALUOp = 4'b0010;
            MemWrite = 1'b1;
            ALUSrc = 1'b1;
            RegWrite = 1'b0;
        end

        Branch_OP: begin
            Branch = 2'b01;
            MemRead = 1'b0;
            MemtoReg = 2'b00;
            ALUOp = 4'b0011;
            MemWrite = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b0;
        end

        Arith_I_OP: begin
            Branch = 2'b00;
            MemRead = 1'b0;
            MemtoReg = 2'b00;
            ALUOp = 4'b0100;
            MemWrite = 1'b0;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
        end

        LUI_OP: begin
            Branch = 2'b00;
            MemRead = 1'b0;
            MemtoReg = 2'b00;
            ALUOp = 4'b0101;
            MemWrite = 1'b0;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
        end

        AUIPC_OP: begin
            Branch = 2'b00;
            MemRead = 1'b0;
            MemtoReg = 2'b10;
            ALUOp = 4'b0110;
            MemWrite = 1'b0;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
        end

        JAL_OP: begin
            Branch = 2'b10;
            MemRead = 1'b0;
            MemtoReg = 2'b11;
            ALUOp = 4'b0111;
            MemWrite = 1'b0;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
        end

        JALR_OP: begin
            Branch = 2'b11;
            MemRead = 1'b0;
            MemtoReg = 2'b11;
            ALUOp = 4'b1000;
            MemWrite = 1'b0;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
        end

        default: begin
            Branch = 2'b00;
            MemRead = 1'b0;
            MemtoReg = 2'b00;
            ALUOp = 4'b0000;
            MemWrite = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b0;
        end
    endcase
end
endmodule
