`timescale 1ns / 1ps



module RISCV_pipeline#(n=32) ( 
    input clk,
    input rst,
    input [1:0] ledSel,
    input [3:0] ssdSel,
    input ssdclk,
    output reg [15:0] LED,
    output reg [12:0] SSD
);

    wire clkdiv2;
    wire [n-1:0] inPC;
    wire [n-1:0] outPC;
    wire [n-1:0] instruction;
    wire RegWrite;
    wire [n-1:0] rd1,rd2,wd,outGen; 
    wire [1:0] Branch;
    wire MemRead, MemWrite, ALUSrc;
    wire [1:0] MemtoReg;
    wire [3:0] ALUOp;
    wire [n-1:0] inALU;
    wire [3:0] sel_ALU;
    wire zeroFlag, carryFlag, overflowFlag, signFlag;
    wire [n-1:0] outALU, EX_MEM_ALU_out, MEM_WB_ALU_out;
    wire [n-1:0] outDatamem;
    wire [n-1:0] adderBranchout,EX_MEM_BranchAddOut;
    wire [n-1:0] shiftOut;
    wire PCSrc;
    
    wire [n-1:0] adderPCout, IF_ID_adderPCout, ID_EX_adderPCout, EX_MEM_adderPCout, MEM_WB_adderPCout;
    wire [n-1:0] IF_ID_Inst, IF_ID_PC;
    
    wire [n-1:0] ID_EX_PC, ID_EX_RegR1, ID_EX_RegR2, ID_EX_Imm; 
    wire [7:0] ID_EX_Ctrl;
    wire [3:0] ID_EX_Func;
    wire [4:0] ID_EX_RS1, ID_EX_RS2, ID_EX_Rd; 
    
    // Rs1 and Rs2 are needed later for the forwarding unit
    wire [n-1:0]  EX_MEM_RegR2; 
    wire [4:0] EX_MEM_Ctrl;
    wire [4:0] EX_MEM_Rd; 
    wire EX_MEM_Zero, EX_MEM_Carry, EX_MEM_Overflow, EX_MEM_SignFlag;


    wire [n-1:0] MEM_WB_Mem_out; 
    wire [1:0] MEM_WB_Ctrl;
    wire [4:0] MEM_WB_Rd;
    
    
    wire [4:0] EX_controls = {ALUSrc, ALUOp};
    wire [3:0] MEM_controls = {Branch, MemRead, MemWrite};
    wire [2:0] WB_controls = {RegWrite, MemtoReg};
    
    wire [2:0] ID_EX_WB_controls, EX_MEM_WB_controls, MEM_WB_WB_controls;
    wire [3:0] ID_EX_MEM_controls, EX_MEM_MEM_controls;
    wire [4:0] ID_EX_EX_controls;
    
    wire [1:0] forwardA, forwardB;
    wire [n-1:0] ALU_forwarding_input1, ALU_forwarding_input2;
    wire stall;  // Signal from hazard detection unit
    
    wire [2:0] H_WB_controls;
    wire [4:0] H_EX_controls;
    wire [3:0] H_MEM_controls;
    
    wire [n-1:0] NOP = 32'b0000000_00000_00000_000_00000_0110011;
    wire [n-1:0] instruction_or_nop;
    wire flush_ID, halt;
    
    
    wire [2:0] ID_EX_WB_controls_pre_flush;
    wire [3:0] ID_EX_MEM_controls_pre_flush;
    wire [4:0] ID_EX_EX_controls_pre_flush;
    
    wire [2:0] cycle_counter;
    wire [3:0] EX_MEM_Func;

    wire [n-1:0] out_memory, mem_data_out;
    
    wire [1:0] branched_PC;
    
    wire [n-1:0] A3out, MEM_WB_PC_plus_ALU_out, EX_MEM_PC_plus_ALU_out;
    
    wire [11:0] addr;
    assign addr = {EX_MEM_ALU_out[7:2],outPC[7:2]};


//clk divider

    clk_divider clk2(
         clk,
         rst,
         clkdiv2
     );
//PC
    
    N_bit_reg#(.n(32)) PC(.clk(clkdiv2),.rst(rst),.load((~stall && ~halt)),.D(inPC),.Q(outPC));
    
    
    
    //add 4 + PC
    
     Ripple_Carry_Adder#(.n(n)) A1(
               .a(outPC),
               .b(32'd4),
               .cin(1'b0),
               .sum(adderPCout)
               );
    
    
              
      
    //Single Memory Component
    
    Mem #(32) singlememory(
        .clk(clk),
        .clkdiv2(clkdiv2),
        .MemRead(EX_MEM_MEM_controls[1]),  // Use pipelined control signal
        .MemWrite(EX_MEM_MEM_controls[0]), // Use pipelined control signal
        .addr(addr),
        .funct3(EX_MEM_Func[2:0]),
        .data_in(EX_MEM_RegR2),
        .data_out(out_memory)
    );

    
    
    //instruction memory
    
//    InstMem#(.n(n)) IM(
//        outPC[7:2],
//        instruction
//     );
     
     // Multiplexer to select between fetched instruction and NOP
     nbit_mux #(32) flush_IF_mux(
         .a(out_memory),
         .b(NOP),
         .sel(PCSrc),
         .out(instruction_or_nop)
     );
    

//IF_ID pipeline
    N_bit_reg #(96)IF_ID (
        .clk(clk),
        .rst(rst),
        .load(~stall && ~halt),
        .D({outPC,instruction_or_nop,adderPCout}),
        .Q({IF_ID_PC,IF_ID_Inst,IF_ID_adderPCout})
    );


// Hazard detection unit
    HazardUnit HDU(
        .IF_ID_RS1(IF_ID_Inst[19:15]),
        .IF_ID_RS2(IF_ID_Inst[24:20]),
        .ID_EX_RD(ID_EX_Rd),
        .ID_EX_MemRead(ID_EX_MEM_controls[1]),  // MemRead signal from ID/EX
        .stall(stall)
    );
    
    Halting_Unit HU(
        IF_ID_Inst[6:0],
        halt
        );
    
    
    
//Register file

  regFile#(.n(n)) RF(
        .clk(clk),
        .rst(rst),
        .RegWrite(MEM_WB_WB_controls[2]),
        .rr1(IF_ID_Inst[19:15]),
        .rr2(IF_ID_Inst[24:20]),
        .wr(MEM_WB_Rd),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
     );
        
     //immediate generator
     
    immGen#(.n(n)) IG(
        .inst(IF_ID_Inst),
        .gen_out(outGen)
     );
     
     assign flush_ID = stall | PCSrc;
     
     //Hazard Mux
     
      nbit_mux#(.n(12)) hazardMux(
            .a({WB_controls, MEM_controls, EX_controls}),
            .b(12'b0),
            .sel(flush_ID),
            .out({H_WB_controls, H_MEM_controls, H_EX_controls})
         );
     
     //control unit
     
     control_unit CU(
     .inst(IF_ID_Inst[6:2]),
     .Branch(Branch),
     .MemRead(MemRead), 
     .MemtoReg(MemtoReg),
     .MemWrite(MemWrite),
     .ALUSrc(ALUSrc),
     .RegWrite(RegWrite),
     .ALUOp(ALUOp)
     );




    N_bit_reg #(191) ID_EX(
    .clk(clk),
    .rst(rst),
    .load(1'b1),
    .D({
        // Control signals grouped by stage
        H_WB_controls,     // 3 bits
        H_MEM_controls,    // 4 bits
        H_EX_controls,     // 5 bits
        
        // Data signals
        IF_ID_PC,                            // 32 bits
        rd1,                                 // 32 bits
        rd2,                                 // 32 bits
        outGen,                              // 32 bits
        {IF_ID_Inst[30], IF_ID_Inst[14:12]}, // 4 bits
        IF_ID_Inst[19:15],                   // 5 bits
        IF_ID_Inst[24:20],                   // 5 bits
        IF_ID_Inst[11:7],                     // 5 bits
        IF_ID_adderPCout
    }),
    .Q({
        ID_EX_WB_controls_pre_flush,  // 3 bits
        ID_EX_MEM_controls_pre_flush, // 4 bits
        ID_EX_EX_controls_pre_flush,  // 5 bits
        
        ID_EX_PC,
        ID_EX_RegR1,
        ID_EX_RegR2,
        ID_EX_Imm,
        ID_EX_Func,
        ID_EX_RS1,
        ID_EX_RS2,
        ID_EX_Rd,
        ID_EX_adderPCout
    })
);


nbit_mux #(12) flush_EX_WB_mux(
    .a({ID_EX_WB_controls_pre_flush,ID_EX_MEM_controls_pre_flush,ID_EX_EX_controls_pre_flush}),
    .b(12'b0),
    .sel(PCSrc),
    .out({ID_EX_WB_controls, ID_EX_MEM_controls, ID_EX_EX_controls})
);

//ALU
 nbit_mux#(.n(n)) M1(
        .a(ALU_forwarding_input2),
        .b(ID_EX_Imm),
        .sel(ID_EX_EX_controls[4]),
        .out(inALU)
     );
     
     //ALU control unit
     
     ALU_C_U ACU(
        .inst1(ID_EX_Func[2:0]),
        .inst2(ID_EX_Func[3]),
        .ALUOp(ID_EX_EX_controls[3:0]),
        .ALU_selection(sel_ALU)
         );
         
         
      //The Arithmetic Logic Unit
      
      ALU#(.n(n)) ALU_inst(
          .a(ALU_forwarding_input1),
          .b(inALU),
          .sel(sel_ALU),
          .shift_places(inALU[4:0]),
          .zeroFlag(zeroFlag),
          .carryFlag(carryFlag),
          .overflowFlag(overflowFlag),
          .signFlag(signFlag),
          .ALU_out(outALU)
          );
          
          
       //forwardingUnit and its two mux
       
       forwardingUnit FWD_UNIT(
              .ID_EX_RS1(ID_EX_RS1),
              .ID_EX_RS2(ID_EX_RS2),
              .EX_MEM_Rd(EX_MEM_Rd),
              .MEM_WB_Rd(MEM_WB_Rd),
              .EX_MEM_RegWrite(EX_MEM_WB_controls[2]),
              .MEM_WB_RegWrite(MEM_WB_WB_controls[2]),
              .forwardA(forwardA),
              .forwardB(forwardB)
          );
          
          
        mux4by1 #(n) MUX_FWD_A(
                 .a(ID_EX_RegR1),         // Original value from ID/EX register
                 .b(wd),                  // Value from WB stage (MEM/WB)
                 .c(EX_MEM_ALU_out),      // Value from EX/MEM stage
                 .d(0),
                 .sel(forwardA),
                 .out(ALU_forwarding_input1)
             );
         
         mux4by1 #(n) MUX_FWD_B(
                     .a(ID_EX_RegR2),         // Original value from ID/EX register
                     .b(wd),                  // Value from WB stage (MEM/WB)
                     .c(EX_MEM_ALU_out),      // Value from EX/MEM stage
                     .d(0),
                     .sel(forwardB),
                     .out(ALU_forwarding_input2)
                 );   
          
//          //shift
//           nbit_shift_left#(.n(n)) SL(
//            .in(ID_EX_Imm), 
//            .out(shiftOut)
//       );

  //branching adder
       
       Ripple_Carry_Adder#(.n(n)) A2(
           .a(ID_EX_PC),
           .b(ID_EX_Imm),
           .cin(1'b0),
           .sum(adderBranchout)
       );
       
        Ripple_Carry_Adder#(.n(n)) A3(
         .a(ID_EX_PC),
         .b(outALU),
         .cin(1'b0),
         .sum(A3out)
       );



//register
        N_bit_reg #(180) EX_MEM (
            .clk(clk),
            .rst(rst),
            .load(1'b1),
            .D({
                ID_EX_WB_controls,   // WB controls (3 bits)
                ID_EX_MEM_controls,  // MEM controls (4 bits)
                adderBranchout,
                zeroFlag,
                carryFlag,
                overflowFlag,
                signFlag,
                outALU,
                ALU_forwarding_input2,
                ID_EX_Rd,
                ID_EX_Func,
                A3out,
                ID_EX_adderPCout
                }),
            .Q({
                EX_MEM_WB_controls,
                EX_MEM_MEM_controls,
                EX_MEM_BranchAddOut,
                EX_MEM_Zero,
                EX_MEM_Carry,
                EX_MEM_Overflow,
                EX_MEM_SignFlag,
                EX_MEM_ALU_out,
                EX_MEM_RegR2,
                EX_MEM_Rd,
                EX_MEM_Func,
                EX_MEM_PC_plus_ALU_out,
                EX_MEM_adderPCout
                }));


        assign PCSrc = (branched_PC != 0);

    BranchUnit BU(
        .carryFlag(EX_MEM_Carry),
        .zeroFlag(EX_MEM_Zero),
        .overflowFlag(EX_MEM_Overflow),
        .signFlag(EX_MEM_SignFlag),
        .funct3(EX_MEM_Func[2:0]),
        .branchSignal(EX_MEM_MEM_controls[3:2]), // Branch signal from pipeline register
        .out(branched_PC)
    );
    
          mux4by1 muxPC(
         .a(adderPCout),
         .b(EX_MEM_BranchAddOut),
         .c(EX_MEM_BranchAddOut),
         .d(EX_MEM_ALU_out),
         .sel(branched_PC),
         .out(inPC)
      );

        
        
 //Data memory
       
//       DataMem #(.n(n)) DM( 
//            .clk(clk),
//            .MemRead(EX_MEM_MEM_controls[1]),
//            .MemWrite(EX_MEM_MEM_controls[0]),
//            .addr(EX_MEM_ALU_out[7:2]),
//            .data_in(EX_MEM_RegR2),
//            .data_out(outDatamem)
//       );
       


        N_bit_reg #(136) MEM_WB (
            .clk(clk),
            .rst(rst),
            .load(1'b1),
            .D({
                EX_MEM_WB_controls,  // WB controls (3 bits),
                out_memory,
                EX_MEM_ALU_out,
                EX_MEM_PC_plus_ALU_out,
                EX_MEM_Rd,
                EX_MEM_adderPCout
                }), 
            .Q({
                MEM_WB_WB_controls,
                MEM_WB_Mem_out,
                MEM_WB_ALU_out,
                MEM_WB_PC_plus_ALU_out,
                MEM_WB_Rd,
                MEM_WB_adderPCout
                }));
             
        
        
//The mux that branch 
//    nbit_mux#(.n(n)) M3(
//          .a(adderPCout),
//          .b(EX_MEM_BranchAddOut),
//          .sel(PCSrc),
//          .out(inPC)
//       );
       

       
       
// mux in current pipelined design
       mux4by1 muxRd(
           .a(MEM_WB_ALU_out),         // ALU result
           .b(MEM_WB_Mem_out),         // Memory data
           .c(MEM_WB_PC_plus_ALU_out), // PC + ALU result (for AUIPC)
           .d(MEM_WB_adderPCout),       // PC + 4 (for JAL/JALR)
           .sel(MEM_WB_WB_controls[1:0]), // MemtoReg control signals
           .out(wd)
       );

       
// LED and SSD outputs case statements        
       
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
               4'b1011: SSD = out_memory[12:0];
           endcase
           
           case(ledSel)
               2'b00: LED = instruction_or_nop[15:0];
               2'b01: LED = instruction_or_nop[31:16];
               2'b10: LED = {2'b0,ALUOp,sel_ALU,zeroFlag,PCSrc};
           endcase
       end       

// all modules instantiations

endmodule