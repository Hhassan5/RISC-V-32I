# RISC-V 5-Stage Pipelined Processor
A complete implementation of a 32-bit RISC-V processor with 5-stage pipeline architecture, featuring advanced hazard detection, data forwarding, and unified memory design. This project demonstrates comprehensive understanding of computer architecture principles and modern processor design techniques.
## File Structure
├── RISCV_pipeline.v          # Top-level pipelined processor module
├── PC.v                      # Program Counter
├── Mem.v                     # Unified memory component
├── ALU.v                     # Arithmetic Logic Unit
├── regFile.v                 # 32-register register file
├── control_unit.v            # Main instruction decoder
├── HazardUnit.v              # Pipeline hazard detection logic
├── forwardingUnit.v          # Data forwarding control
├── BranchUnit.v              # Branch condition evaluation
├── ALU_C_U.v                 # ALU control unit
├── immGen.v                  # Immediate value generator
├── clk_divider.v             # Clock frequency divider
├── Halting_Unit.v            # System instruction handler
└── utility_modules/          # Supporting components (muxes, registers, adders)
## Data Path Diagram
![PC](https://github.com/user-attachments/assets/b3c5ec00-98ef-44cf-a204-01d6fecb708f)
