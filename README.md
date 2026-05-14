# AXI4-Lite UVM Verification Environment

## Project Overview
This repository contains a comprehensive **UVM (Universal Verification Methodology)** testbench developed to verify an AXI4-Lite Slave IP. The project demonstrates a full-stack verification approach, starting from interface definitions with SystemVerilog Assertions (SVA) to automated regression testing and achieving 100% Functional Coverage.

## Key Features & Verification Strategy
- **Constrained Random Verification (CRV):** Implemented randomized sequences to drive high-volume traffic while respecting AXI4-Lite protocol constraints.
- **Protocol Checking with SVA:** Embedded SystemVerilog Assertions within the interface (`axi4_lite_if.sv`) to strictly monitor AXI handshake rules (VALID/READY) and payload stability at the pin level.
- **Advanced Scoreboard & Reference Model:** Developed an associative array-based reference memory model to automatically predict and compare DUT responses on the fly.
- **Register Abstraction Layer (RAL):** Modeled the DUT's internal registers (`sy_reg_block.sv`) and utilized Backdoor Access for zero-delay hardware state inspection.
- **Complex Scenario Injection:** Designed Virtual Sequencers to handle corner cases, including an **Error Injection Sequence** that intentionally targets out-of-bound memory addresses to verify the DUT's `bresp/rresp` error handling logic.
- **Automated Regression (CI/CD Basics):** Created a `Makefile` to automate compilation, multi-seed regression runs, and coverage database merging.

## Architecture Block Diagram
<img width="599" height="327" alt="Image" src="https://github.com/user-attachments/assets/cffd6f8c-efda-4523-a649-96ad53f1344b" />


## Directory Structure
```text
├── rtl/       # Design Under Test (AXI4-Lite Slave)
├── src/       # UVM Components (Agent, Monitor, Scoreboard, RAL, etc.)
├── tb/        # Testbench Top and AXI Interface (with SVA)
├── sim/       # Simulation working directory (logs, coverage databases)
├── scripts/   # Automation scripts and Makefile
└── docs/      # Architecture images and coverage reports
```

##  Verification Results: 100% Functional Coverage
To ensure the robustness of the verification environment, a UVM Subscriber was implemented to collect functional coverage. 

### Overcoming Coverage Holes
Initially, a coverage hole was detected because the random traffic accessed 4 physical registers, while the early RAL model only defined 2. The RAL model was immediately updated to perfectly match the DUT's physical memory map (`ctrl_reg`, `status_reg`, `reg_2`, `reg_3`). 

Furthermore, a specific **Out-of-Bound** bin was added to the coverage model to strictly track the execution of the Error Injection scenarios. As a result, 100% Cross-Coverage (Read/Write operations across all valid and invalid address spaces) was successfully achieved.

<img width="728" height="40" alt="Image" src="https://github.com/user-attachments/assets/d8673ed3-b5fe-4a08-8441-719732a340be" />

## Getting Started (How to Run)
This project includes a `Makefile` configured for Questa/ModelSim environments. 
Navigate to the `scripts/` directory and use the following commands:

**1. Run a single default simulation:**
```bash
make all
```

**2. Run a regression test with multiple random seeds:**
```bash
make regression
```

**3. Merge coverage databases and generate HTML report:**
```bash
make cov_merge
```

**4. Clean simulation artifacts:**
```bash
make clean
```
