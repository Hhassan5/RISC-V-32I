`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/18/2025 11:43:31 AM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    input clk,
    input rst,
    input [1:0] ledSel,
    input [3:0] ssdSel,
    input ssdclk,
    output [15:0] LED,
    output [3:0] Anode,
    output [6:0] Display
    );
    wire [12:0] SSD;
    
    RISC_V#(.n(32)) processor(
    .clk(clk),
    .rst(rst),
    .ledSel(ledSel),
    .ssdSel(ssdSel),
    .ssdclk(ssdclk),
    .LED(LED),
    .SSD(SSD)
    );
    
    Four_Digit_Seven_Segment_Driver_Optimized SSDinst(
    .clk(ssdclk),
    .num(SSD),
    .Anode(Anode),
    .LED_out(Display)
);
    
    
endmodule
