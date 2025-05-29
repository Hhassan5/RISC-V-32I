`timescale 1ns / 1ps

module immGen #(parameter n=32) (
    input [n-1:0] inst,
    output reg [n-1:0] gen_out
);

localparam [4:0] 
    BRANCH_OP   = 5'b11000,
    LOAD_OP     = 5'b00000,
    STORE_OP    = 5'b01000,
    JALR_OP     = 5'b11001,
    JAL_OP      = 5'b11011,
    ARITH_I_OP  = 5'b00100,
    ARITH_R_OP  = 5'b01100,
    AUIPC_OP    = 5'b00101,
    LUI_OP      = 5'b01101,
    SYSTEM_OP   = 5'b11100;

always @(*) begin
    case(inst[6:2])
        BRANCH_OP:  gen_out = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
        LOAD_OP:    gen_out = {{20{inst[31]}}, inst[31:20]};
        STORE_OP:   gen_out = {{20{inst[31]}}, inst[31:25], inst[11:7]};
        LUI_OP:     gen_out = {inst[31:12], 12'b0};
        ARITH_I_OP: gen_out = {{20{inst[31]}}, inst[31:20]};
        AUIPC_OP:   gen_out = {inst[31:12], 12'b0};
        JAL_OP:     gen_out = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0};
        JALR_OP:    gen_out = {{20{inst[31]}}, inst[31:20]};
        default:    gen_out = {{20{inst[31]}}, inst[31:20]};
    endcase
end

endmodule