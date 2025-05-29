`timescale 1ns / 1ps

module clk_divider(
    input clk_in,
    input rst,
    output reg clk_out
);

    always @(posedge clk_in or posedge rst) begin
        if (rst) begin
            clk_out <= 0;
        end else begin
            clk_out <= ~clk_out;
        end
    end

endmodule
