`timescale 1ns / 1ps

module riscv_tb();

    reg [1:0] ledSel;
    reg [3:0] ssdSel;
    reg rst;
    reg clk;
    reg ssdclk;
    wire [15:0] LED;
    wire [12:0] SSD;
    
    RISC_V#(.n(32)) RV(
        .clk(clk),
        .rst(rst),
        .ledSel(ledSel),
        .ssdSel(ssdSel),
        .ssdclk(ssdclk),
        .LED(LED),
        .SSD(SSD)
        );
    
    initial begin
        clk = 0;
        forever begin
          #5;
          clk = ~clk;
        end
    end
    
    initial begin
        rst = 1'b1;
        #10
        rst = 0;
        
        ledSel = 2'b00;
        ssdSel = 4'b1011;
        
        repeat(5) @(posedge clk);
        
        
        ledSel = 2'b00;
        ssdSel = 4'b1011;
        
        
    end
    
endmodule
