`timescale 1ns / 1ps

module RISC_V#(n=32)(
    input clk,
    input rst,
    input [1:0] ledSel,
    input [3:0] ssdSel,
    input ssdclk,
    output reg [15:0] LED,
    output reg [12:0] SSD
    );
    
    wire [n-1:0] inPC;
    wire [n-1:0] outPC;
    wire [n-1:0] instruction;
    wire reg_write;
    wire [n-1:0] rd1,rd2,wd,outGen; 
    wire [1:0] Branch, MemtoReg;
    wire MemRead, MemWrite, ALUSrc;
    wire [3:0] ALUop;
    wire [n-1:0] inALU;
    wire [3:0] sel_ALU;
    wire zeroFlag, carryFlag, overflowFlag, signFlag;
    wire [n:0] outALU;
    wire [n-1:0] outDatamem;
    wire [n:0] adderPCout,adderBranchout;
    wire [n-1:0] shiftOut;
    wire Bsel;
    wire [4:0] shift_places;
    wire [2:0] funct3;
    wire [1:0] branched_PC;
    wire [n-1:0] A3out;
    //PC
    
    N_bit_reg#(.n(n)) PC(.clk(clk),
                         .rst(rst),
                         .load(1),
                         .D(inPC),
                         .Q(outPC)
                         );
    
    //instruction memory
    
    InstMem#(.n(n)) IM(outPC[7:2],
                       instruction
                       );
    
    //register file
    
    regFile#(.n(n)) RF(
        .clk(clk),
        .rst(rst),
        .reg_write(reg_write),
        .rr1(instruction[19:15]),
        .rr2(instruction[24:20]),
        .wr(instruction[11:7]),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
     );
        
     //immediate generator
     
    immGen#(.n(n)) IG(
        .inst(instruction),
        .gen_out(outGen)
     );
     
     //control unit
     
     control_unit CU(
     .inst(instruction[6:2]),
     .Branch(Branch),
     .MemRead(MemRead), 
     .MemtoReg(MemtoReg),
     .MemWrite(MemWrite),
     .ALUSrc(ALUSrc),
     .RegWrite(reg_write),
     .ALUOp(ALUop)
     );
     
     //The mux for read data 2 or the immediate generator
     
     nbit_mux#(.n(n)) M1(
        .a(rd2),
        .b(outGen),
        .sel(ALUSrc),
        .out(inALU)
     );
     
     //ALU control unit
     
     ALU_C_U ACU(
        .inst1(instruction[14:12]),
        .inst2(instruction[30]),
        .ALUOp(ALUop),
        .ALU_selection(sel_ALU)
         );
         
      //The Arithmetic Logic Unit
      
      ALU#(.n(n)) ALU_inst(
          .a(rd1),
          .b(inALU),
          .sel(sel_ALU),
          .shift_places(inALU[4:0]),
          .zeroFlag(zeroFlag),
          .carryFlag(carryFlag),
          .overflowFlag(overflowFlag),
          .signFlag(signFlag),
          .ALU_out(outALU)
          );
          
       //Data memory
       
       DataMem #(.n(n)) DM(
            .clk(clk),
            .MemRead(MemRead),
            .MemWrite(MemWrite),
            .addr(outALU[7:2]),
            .funct3(instruction[14:12]),
            .data_in(rd2),
            .data_out(outDatamem)
       );
       
       
       
       //MUX at the end (write back)
       
//       nbit_mux#(.n(n)) M2(
//          .a(outALU),
//          .b(outDatamem),
//          .sel(MemtoReg),
//          .out(wd)
//       );
       
       
       BranchUnit BU(
           .carryFlag(carryFlag),
            .zeroFlag(zeroFlag),
            .overflowFlag(overflowFlag),
            .signFlag(signFlag),
            .funct3(instruction[14:12]),
            .branchSignal(Branch),
            .out(branched_PC)
       );
       
       //Program counter adder incrementing by 4
       
       Ripple_Carry_Adder#(.n(n)) A1(
           .a(outPC),
           .b(32'd4),
           .cin(1'b0),
           .sum(adderPCout)
           );
           
       //nbit shifting for branchcing and more
       
//       nbit_shift_left#(.n(n)) SL(
//            .in(outGen), 
//            .out(shiftOut)
//       );
       
       
       //branching adder
       
       Ripple_Carry_Adder#(.n(n)) A2(
           .a(outPC),
           .b(outGen),
           .cin(1'b0),
           .sum(adderBranchout)
       );
       
       //And gate for branching and zeroflag
       
//       assign Bsel = Branch & zeroFlag;


       mux4x1 muxPC(
           .a(adderPCout),
           .b(adderBranchout),
           .c(adderBranchout),
           .d(outALU),
           .sel(branched_PC),
           .out(inPC)
        );
       
       
//       nbit_mux#(.n(n)) M3(
//          .a(adderPCout),
//          .b(adderBranchout),
//          .sel(Bsel),
//          .out(inPC)
//       ); 

         Ripple_Carry_Adder#(.n(n)) A3(
           .a(outPC),
           .b(outALU),
           .cin(1'b0),
           .sum(A3out)
         );
         
         
         mux4x1 muxRd(
             .a(outALU),
             .b(outDatamem),
             .c(A3out),
             .d(adderPCout),
             .sel(MemtoReg),
             .out(wd)
          );
         
         
       
       always @(*) begin
           case(ssdSel) 
               4'b0000: SSD = outPC[12:0];
               4'b0001: SSD = adderPCout[12:0];
               4'b0010: SSD = adderBranchout[12:0];
               4'b0011: SSD = inPC[12:0];
               4'b0100: SSD = rd1[12:0];
               4'b0101: SSD = rd2[12:0];
               4'b0110: SSD = wd[12:0];
               4'b0111: SSD = outGen[12:0];
               4'b1000: SSD = shiftOut[12:0];
               4'b1001: SSD = inALU[12:0];
               4'b1010: SSD = outALU[12:0];
               4'b1011: SSD = outDatamem[12:0];
           endcase
           
           case(ledSel)
               2'b00: LED = instruction[15:0];
               2'b01: LED = instruction[31:16];
               2'b10: LED = {2'b0,ALUop,sel_ALU,zeroFlag,branched_PC};
           endcase
       end      
endmodule
