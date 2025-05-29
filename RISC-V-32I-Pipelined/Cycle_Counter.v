`timescale 1ns / 1ps

module CycleCounter(
    input clk,
    input rst,
    output reg [2:0] cycle_counter
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            cycle_counter <= 3'b000;
        else if (cycle_counter == 3'b010)
            cycle_counter <= 3'b000;
        else
            cycle_counter <= cycle_counter + 1;
    end
endmodule
