# RISC-V 5-Stage Pipelined Processor
A complete implementation of a 32-bit RISC-V processor with 5-stage pipeline architecture, featuring advanced hazard detection, data forwarding, and unified memory design. This project demonstrates comprehensive understanding of computer architecture principles and modern processor design techniques.
## RISC-V Instruction Support
- R-Type Instructions: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
- I-Type Instructions: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI, LB, LH, LW, LBU, LHU, JALR
- S-Type Instructions: SB, SH, SW
- B-Type Instructions: BEQ, BNE, BLT, BGE, BLTU, BGEU
- U-Type Instructions: LUI, AUIPC
- J-Type Instructions: JAL
- System Instructions: ECALL, EBREAK, FENCE, FENCE.TSO, PAUSE (implemented as halt operations)

## Data Path Diagram
![PC](https://github.com/user-attachments/assets/b3c5ec00-98ef-44cf-a204-01d6fecb708f)

## Memory Organization
### The processor uses a unified memory architecture with the following layout:
- Instructions: Memory addresses 0-63 (word-addressable)
- Data: Memory addresses 64-127 (word-addressable)


## Pre-loaded Test Program
- The memory is initialized with a comprehensive test suite covering:
- Basic arithmetic operations (ADD, SUB, ADDI)
- Logical operations (XOR, OR, AND, shifts)
- Memory operations (LW, SW, LB, LH, SB, SH)
- Control flow (JAL, JALR, branches)
- Upper immediate instructions (LUI, AUIPC)
- System instructions (ECALL, EBREAK, FENCE)


## Installation and Usage
### Prerequisites:
- Xilinx Vivado (2018 or later)
- Nexys A7 FPGA development board
- ModelSim/QuestaSim or compatible Verilog simulator (for simulation)


## Design Decisions and Trade-offs
### Word-Addressable Memory
* Rationale: Simplified debugging and test case development
* Trade-off: Non-standard addressing scheme vs. development efficiency
* Future Work: Can be easily modified to byte-addressable implementation
### Unified Memory Architecture
* Advantage: Simplified memory controller and reduced resource usage
* Implementation: Dual-clock operation prevents instruction/data conflicts
* Scalability: Design supports easy expansion to Harvard architecture
### Static Branch Prediction
* Current: Simple flush-on-branch strategy
* Performance: Minimal impact due to short pipeline depth
* Enhancement Opportunity: Dynamic prediction could improve performance






