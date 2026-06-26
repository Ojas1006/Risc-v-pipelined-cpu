# RISC-V Pipelined CPU (RV32I)

## Overview

A 5-stage pipelined RV32I RISC-V processor implemented in Verilog, built as a learning project. The design follows the classic pipeline structure from Patterson & Hennessy's *Computer Organization and Design: RISC-V Edition* (Fig. 4.66), with additional reference to [AkeelMedina22's](https://github.com/AkeelMedina22) RISC-V pipelined CPU implementation.

## Architecture

The processor implements the standard 5-stage pipeline:

**IF → ID → EX → MEM → WB**

Key architectural features:
- **Forwarding** — resolves data hazards by forwarding results from EX/MEM and MEM/WB stages back into the EX stage inputs, avoiding unnecessary stalls
- **Hazard Detection Unit** — detects load-use and other hazards and inserts stalls where forwarding alone can't resolve them
- **Branch Flushing** — flush logic is split into three independent signals: `flush_ifid`, `flush_idex`, and `flush_exmem`
  - `JAL`'s jump signal routes exclusively to `flush_ifid`
  - Branch resolution (handled in the EX stage) correctly targets both `flush_ifid` and `flush_idex`

## Features

- Full RV32I instruction set support
- Complete forwarding paths to eliminate avoidable pipeline stalls
- Robust branch/jump handling, including a resolved JAL self-flush bug
- Synthesizable RTL — verified through both FPGA and ASIC implementation flows

## Repository Structure

```
.
├── RISC_V_pipeline.v      # Top-level module integrating all submodules
├── src/
│   ├── modules/           # Core submodules (pipeline regs, ALU, control logic, etc.)
│   └── memory/            # Instruction and data memory implementations
```

## Modules Implemented

**Pipeline Registers**
- IF/ID, ID/EX, EX/MEM, MEM/WB

**Core Datapath**
- Register file
- ALU
- ALU control
- Immediate generator

**Memory**
- Instruction memory
- Data memory 

**Control**
- Control unit
- Forwarding unit
- Hazard detection unit
- Branch unit
- Flush unit

**Supporting Logic**
- Program counter (PC)
- Muxes
- Adders
- Instruction parser

## Test Results

- Tested jump, branch, flush, forwarding unit and other simple instructions

## FPGA Implementation Results (Artix-7)

Synthesized and implemented using Xilinx Vivado, targeting an Artix-7 device.

| Metric | Result |
|---|---|
| Target Frequency | 100 MHz |
| WNS (Worst Negative Slack) | +0.454 ns |
| TNS (Total Negative Slack) | 0 ns |
| Timing Violations | 0 |
| LUTs | ~3313 |
| Flip-Flops | ~2078 |
| Power | 0.187 W |

## ASIC Implementation Results
 
Implemented using OpenLane with the Sky130A PDK (`sky130_fd_sc_hd` standard cell library).
 
| Metric | Result |
|---|---|
| Flow | OpenLane + Sky130A PDK (`sky130_fd_sc_hd`) |
| Fmax | ~136 MHz @ 10 ns clock |
| Cell Area | ~175,065 µm² |
| Die Size | ~879 × 879 µm |
| Power | ~33.9 mW |
 
`FP_CORE_UTIL = 0.20` and `PL_TARGET_DENSITY = 0.30` were chosen to prioritize timing closure over density.
 
## Future Work / Roadmap
 
- Tighter clock period sweep (5/7/8/10/15 ns) for true Fmax characterization
- Move branch resolution to the ID stage
- 2-bit dynamic branch predictor with a Branch History Table (BHT)
- Carry-select adder for the ALU critical path
- Validation against `riscv-tests`
