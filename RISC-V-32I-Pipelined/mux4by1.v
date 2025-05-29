`timescale 1ns / 1ps

module mux4by1 #(parameter n = 32)(
    input [n-1:0] a, b, c, d,
    input [1:0] sel,
    output reg [n-1:0] out
);
    always @(*) begin
        case(sel)
            2'b00: out = a;  // Original value from ID/EX register
            2'b01: out = b;  // Forwarded value from MEM/WB stage
            2'b10: out = c;  // Forwarded value from EX/MEM stage
            2'b11: out = d;  // This input is not used in our forwarding logic
            default: out = a;
        endcase
    end
endmodule

