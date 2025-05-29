`timescale 1ns / 1ps

module Mem #(parameter n = 32)(
    input wire clk,
    input wire clkdiv2,
    // Memory control signals
    input wire MemRead,
    input wire MemWrite,
    input wire [11:0] addr,    // Memory address
    input wire [2:0] funct3,  // Function code for load/store type
    input wire [n-1:0] data_in,    // Data to write
    output reg [n-1:0] data_out
);
    // Unified memory array (64 words)
    reg [n-1:0] mem [0:127];
    wire [5:0] x, y;
    assign y = addr[5:0];  // Instruction mem address
    assign x = addr[11:6];  // Data Mem address
    localparam Data_Offset = 64;

    
    //localparam DATA_OFFSET = 7'd64;
    
    // Load types
    localparam [2:0]
        LB  = 3'b000,
        LH  = 3'b001,
        LW  = 3'b010,
        LBU = 3'b100,
        LHU = 3'b101;
    
    // Store types
    localparam [2:0]
        SB = 3'b000,
        SH = 3'b001,
        SW = 3'b010;
    
    
    // Data memory read logic (combinational)
    always @(*) begin
        if (~clkdiv2) begin
            if (MemRead) begin
                // Data memory read with appropriate formatting based on load type
                case(funct3)
                    LB:  data_out = {{24{mem[x + Data_Offset][7]}}, mem[x + Data_Offset][7:0]};       // Sign-extended byte
                    LH:  data_out = {{16{mem[x + Data_Offset][15]}}, mem[x + Data_Offset][15:0]};     // Sign-extended half-word
                    LW:  data_out = mem[x + Data_Offset];                                  // Full word
                    LBU: data_out = {24'b0, mem[x + Data_Offset][7:0]};                    // Zero-extended byte
                    LHU: data_out = {16'b0, mem[x + Data_Offset][15:0]};                   // Zero-extended half-word
                    default: data_out = 32'h0;
                endcase
            end else data_out = 32'h0;
        end
        else
            data_out = mem[y];
    end
    
    // Memory write logic (synchronous)
    always @(posedge clk) begin
        if (MemWrite) begin
            case(funct3)
                SB: mem[x + Data_Offset][7:0] <= data_in[7:0];
                SH: mem[x + Data_Offset][15:0] <= data_in[15:0]; 
                SW: mem[x + Data_Offset] <= data_in;
                default: mem[x + Data_Offset] <= 0;                              // No operation
            endcase
        end
    end
    
    // Initialize memory with both instructions and data
    initial begin
        // Instructions (first part of memory)
        mem[0]=32'b0000000_00000_00000_000_00000_0110011 ; //add x0, x0, x0
        mem[1]=32'b00000000000000000010000010000011 ; //lw x1, 256(x0) ---> x1 = 17
        mem[2]=32'b00000000010000000010000100000011 ; //lw x2, 260(x0) ---> x2 = 9
        mem[3]=32'b00000000100000000010000110000011 ; //lw x3, 264(x0) ---> x3 = 25
        mem[4]=32'b000000000101_00010_000_00100_0010011 ; //addi x4, x2, 5 ---> x4 = 14
        mem[5]=32'b00000000000000000101_00101_0110111 ; //lui x5, 5 ---> x5 = 20480
        mem[6]=32'b00000000000000000010_00110_0010111 ; //auipc x6, 2 ---> x6 = PC + 8192
        mem[7]=32'b000100000000_00000_000_01001_0000011 ; //lb x9, 256(x0) ---> x9 = sign_extend(mem[64][7:0]) = 17
        mem[8]=32'b000100000100_00000_001_01010_0000011 ; //lh x10, 260(x0) ---> x10 = sign_extend(mem[65][15:0]) = 9
        mem[9]=32'b000100001000_00000_010_01011_0000011 ; //lw x11, 264(x0) ---> x11 = 25
        mem[10]=32'b000100000000_00000_100_01100_0000011 ; //lbu x12, 256(x0) ---> x12 = zero_extend(mem[64][7:0]) = 17
        mem[11]=32'b000100000100_00000_101_01101_0000011 ; //lhu x13, 260(x0) ---> x13 = zero_extend(mem[65][15:0]) = 9
        mem[12]=32'b0001000_00001_00000_000_01100_0100011 ; //sb x1, 268(x0) ---> mem[67][7:0] = x1[7:0] = 17
        mem[13]=32'b0001000_00010_00000_001_10000_0100011 ; //sh x2, 272(x0) ---> mem[68][15:0] = x2[15:0] = 9
        mem[14]=32'b0001000_00011_00000_010_10100_0100011 ; //sw x3, 276(x0) ---> mem[69] = x3 = 25
        mem[15]=32'b000000001010_00001_000_01110_0010011 ; //addi x14, x1, 10 ---> x14 = 17 + 10 = 27
        mem[16]=32'b000000001010_00010_010_01111_0010011 ; //slti x15, x2, 10 ---> x15 = (x2 < 10) ? 1 : 0 = 1
        mem[17]=32'b000000001010_00011_011_10000_0010011 ; //sltiu x16, x3, 10 ---> x16 = (x3 < 10 unsigned) ? 1 : 0 = 0
        mem[18]=32'b000000000101_00001_100_10001_0010011 ; //xori x17, x1, 5 ---> x17 = 17 ^ 5 = 20
        mem[19]=32'b000000000110_00010_110_10010_0010011 ; //ori x18, x2, 6 ---> x18 = 9 | 6 = 15
        mem[20]=32'b000000010000_00011_111_10011_0010011 ; //andi x19, x3, 16 ---> x19 = 25 & 16 = 16
        mem[21]=32'b0000000_00011_00010_001_10100_0010011 ; //slli x20, x2, 3 ---> x20 = 9 << 3 = 72
        mem[22]=32'b0000000_00010_00011_101_10101_0010011 ; //srli x21, x3, 2 ---> x21 = 25 >> 2 = 6
        mem[23]=32'b0100000_00010_00011_101_10110_0010011 ; //srai x22, x3, 2 ---> x22 = 25 >> 2 = 6 (arithmetic)
        mem[24]=32'b0000000_00010_00001_000_10111_0110011 ; //add x23, x1, x2 ---> x23 = 17 + 9 = 26
        mem[25]=32'b0100000_00010_00011_000_11000_0110011 ; //sub x24, x3, x2 ---> x24 = 25 - 9 = 16
        mem[26]=32'b0000000_00100_00010_001_11001_0110011 ; //sll x25, x2, x4 ---> x25 = 9 << 14 = 147456
        mem[27]=32'b0000000_00011_00010_010_11010_0110011 ; //slt x26, x2, x3 ---> x26 = (x2 < x3) ? 1 : 0 = 1
        mem[28]=32'b0000000_00011_00010_011_11011_0110011 ; //sltu x27, x2, x3 ---> x27 = (x2 < x3 unsigned) ? 1 : 0 = 1
        mem[29]=32'b0000000_00011_00001_100_11100_0110011 ; //xor x28, x1, x3 ---> x28 = 17 ^ 25 = 8
        mem[30]=32'b0000000_00010_00011_101_11101_0110011 ; //srl x29, x3, x2 ---> x29 = 25 >> 9 = 0
        mem[31]=32'b0100000_00010_00011_101_11110_0110011 ; //sra x30, x3, x2 ---> x30 = 25 >> 9 = 0 (arithmetic)
        mem[32]=32'b0000000_00010_00001_110_11111_0110011 ; //or x31, x1, x2 ---> x31 = 17 | 9 = 25
        mem[33]=32'b0000000_00010_00001_111_00101_0110011 ; //and x5, x1, x2 ---> x5 = 17 & 9 = 1
        mem[34]=32'b0000_0000_0000_00000_000_00000_0001111 ; //fence ---> halts execution
        mem[35]=32'b1000_0011_0011_00000_000_00000_0001111 ; //fence.tso ---> halts execution
        mem[36]=32'b0000_0001_0000_00000_000_00000_0001111 ; //pause ---> halts execution
        mem[37]=32'b000000000000_00000_000_00000_1110011 ; //ecall ---> halts execution
        mem[38]=32'b000000000001_00000_000_00000_1110011 ; //ebreak ---> halts execution

        
        // Data values (typically stored at higher memory addresses)
        // These are the initial data values that can be loaded by the program
        mem[64]=32'd17;
        mem[65]=32'd9; 
        mem[66]=32'd25; 
    end
endmodule







