`timescale 1ns / 1ps

module ALU#(n = 32)(
    input [n-1:0] a,
    input [n-1:0] b,
    input [3:0] sel,
    input [4:0] shift_places,
    output reg zeroFlag,
    output reg carryFlag,
    output reg overflowFlag,
    output reg signFlag,
    output reg [n:0] ALU_out
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
    
    wire [n-1:0] b_twos;
    assign b_twos = (sel == ADD) ? b : ~b;

    wire [n:0] sum;
    Ripple_Carry_Adder #(.n(n)) RCA (.a(a), .b(b_twos), .cin(sel[0]), .sum(sum));
    
    always @(*) begin
        ALU_out = 0;
        carryFlag = 0;
        overflowFlag = 0;
        zeroFlag = 0;
        signFlag = 0;

        case (sel)
            ADD:       ALU_out = sum;
            SUB:       ALU_out = sum;
            OR:        ALU_out = a | b;
            AND:       ALU_out = a & b;
            XOR:       ALU_out = a ^ b;
            SRL:       ALU_out = a >> shift_places;
            SRA:       ALU_out = $signed(a) >>> shift_places;
            SLL:       ALU_out = a << shift_places;
            SLT:       ALU_out = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
            SLTU:      ALU_out = (a < b) ? 32'b1 : 32'b0;
            LUI_AUIPC: ALU_out = b;
            default:   ALU_out = 0;
        endcase

        // Flags based on arithmetic result
        carryFlag     = sum[n];
        overflowFlag  = (a[n-1] ^ b_twos[n-1] ^ sum[n-1] ^ sum[n]);
        zeroFlag      = (ALU_out[n-1:0] == 0);
        signFlag      = ALU_out[n-1];
    end
endmodule
