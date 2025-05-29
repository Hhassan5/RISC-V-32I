`timescale 1ns / 1ps



module ALU_C_U(input [14:12] inst1,input inst2, input [3:0] ALUOp, output reg [3:0] ALU_selection

    );
    
    localparam ADD        = 4'b0000;
    localparam SUB        = 4'b0001;
    localparam OR         = 4'b0010;
    localparam AND        = 4'b0011;
    localparam XOR        = 4'b0100;
    localparam SRL        = 4'b0101;
    localparam SRA        = 4'b0110;
    localparam SLL        = 4'b0111;
    localparam SLT        = 4'b1000;
    localparam SLTU       = 4'b1001;
    localparam LUI_AUIPC  = 4'b1010;
    
    always @(*) begin
        if (ALUOp == 4'b0100) begin // I format
            case(inst1)
                3'b000: ALU_selection = ADD; //ADDI
                3'b001: ALU_selection = SLL; //SLLI
                3'b010: ALU_selection = SLT; //SLTI
                3'b011: ALU_selection = SLTU; //SLTIU
                3'b100: ALU_selection = XOR; //XORI
                3'b101: begin
                    if(inst2 == 0)
                        ALU_selection = SRL; //SRLI
                    else
                        ALU_selection = SRA; //SRAI
                end
                3'b110: ALU_selection = OR; //ORI
                3'b111: ALU_selection = AND; //ANDI
            endcase
        end
        else if (ALUOp == 4'b0001 || ALUOp == 4'b0010 || ALUOp == 4'b0111 || ALUOp == 4'b1000) begin
            ALU_selection = ADD; // load, store, JAL, JALR all use ADD
        end
        else if (ALUOp == 4'b0011) begin
            ALU_selection = SUB; // branch uses SUB
        end
        else if (ALUOp == 4'b0000) begin // R format
            case(inst1)
                3'b000: begin
                    if(inst2 == 0)
                        ALU_selection = ADD;
                    else
                        ALU_selection = SUB;
                end
                3'b001: ALU_selection = SLL;
                3'b010: ALU_selection = SLT;
                3'b011: ALU_selection = SLTU;
                3'b100: ALU_selection = XOR;
                3'b101: begin
                    if(inst2 == 0)
                        ALU_selection = SRL;
                    else
                        ALU_selection = SRA;
                end
                3'b110: ALU_selection = OR;
                3'b111: ALU_selection = AND;
            endcase
        end
        else if (ALUOp == 4'b0101 || ALUOp == 4'b0110) begin
            ALU_selection = LUI_AUIPC; // LUI or AUIPC
        end
    end
    
    endmodule