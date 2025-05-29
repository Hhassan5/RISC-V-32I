`timescale 1ns / 1ps


module DataMem #(n=32)(
    input clk,
    input MemRead,
    input MemWrite,
    input [5:0] addr,
    input [2:0] funct3,
    input [n-1:0] data_in,
    output reg [n-1:0] data_out
    );

reg [n-1:0] mem [0:255];


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

// Write logic (synchronous)
always @(posedge clk) begin
    if (MemWrite) begin
        case(funct3)
            SB: mem[addr] <= data_in[7:0];
            SH: begin
                mem[addr]   <= data_in[7:0];
                mem[addr+1] <= data_in[15:8];
            end
            SW: begin
                mem[addr]   <= data_in[7:0];
                mem[addr+1] <= data_in[15:8];
                mem[addr+2] <= data_in[23:16];
                mem[addr+3] <= data_in[31:24];
            end
        endcase
    end
end

// Read logic (asynchronous)
always @(*) begin
    if (MemRead) begin
        case(funct3)
            LB:  data_out = $signed(mem[addr]);
            LH:  data_out = $signed({mem[addr+1], mem[addr]});
            LW:  data_out = {mem[addr+3],mem[addr+2],mem[addr+1],mem[addr]};
            LBU: data_out = {24'b0, mem[addr]};
            LHU: data_out = {16'b0, mem[addr+1], mem[addr]};
            default: data_out = 32'b0;
        endcase
    end
    else begin
        data_out = 32'b0;
    end
end


initial begin
mem[0]=32'd5; 
mem[1]=32'd5; 
mem[2]=32'd25; 
end

    
endmodule
