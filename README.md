# AXI4-Lite UVM Verification 

## Project Overview
This repository contains a comprehensive **UVM (Universal Verification Methodology)** testbench developed to verify an AXI4-Lite Slave IP. Built over an intensive 11-week development cycle, this project demonstrates a full-stack verification pipeline. It covers everything from basic UVM infrastructure and protocol-level assertions to advanced features like a Register Abstraction Layer (RAL), Constrained Random Verification (CRV), and automated CI/CD regression scripts.

## Key Verification Features & Methodologies

* **Constrained Random Verification (CRV):** 
  Defined custom `uvm_sequence_item` classes with `rand` variables. Implemented constraint blocks to ensure 32-bit address alignment and valid data generation, injecting hundreds of randomized transactions into the DUT to thoroughly test its state machine.
* **Protocol Checking with SystemVerilog Assertions (SVA):** 
  Embedded SVA blocks directly inside the AXI4-Lite interface. This acts as a real-time hardware monitor to instantly catch protocol violations, such as ensuring `VALID`/`READY` handshake hold rules, payload stability during wait states, and strictly checking for unknown (`X` or `Z`) states during reset.
* **Advanced Scoreboard & Reference Model:** 
  Developed a zero-delay software reference model using an associative array. The Scoreboard automatically predicts expected data upon write operations and performs on-the-fly comparisons against actual read data from the DUT.
* **Register Abstraction Layer (RAL):** 
  Modeled the DUT's memory map using `uvm_reg_block` and `uvm_reg`. Implemented a custom RAL Adapter to translate register transactions into AXI bus transactions, and established **Backdoor Access** for zero-delay hardware state inspection without consuming simulation time.
* **Virtual Sequencer & Complex Scenario Injection:** 
  Designed virtual sequences to test complex corner cases. This includes Read-Modify-Write operations and an **Error Injection Sequence** that intentionally targets out-of-bound memory addresses to verify the DUT's `bresp/rresp` error handling logic.
* **Automated Regression & CI/CD Pipeline:** 
  Developed a comprehensive `Makefile` to automate compilation, execute multi-seed regression runs, parse log files for Pass/Fail extraction, and merge coverage databases (`.ucdb`) into a unified HTML report.

## Architecture & Directory Structure

![UVM Architecture](docs/uvm_architecture.png)
*(Note: Replace with your actual block diagram image)*

```text
├── rtl/       # Design Under Test (AXI4-Lite Slave)
├── src/       # UVM Components (Agent, Monitor, Scoreboard, RAL, etc.)
├── tb/        # Testbench Top and AXI Interface (with SVA)
├── sim/       # Simulation working directory (Makefile, logs, coverage databases)
├── scripts/   # Automation scripts (Python log parsers, etc.)
└── docs/      # Architecture images, waveforms, and coverage reports
```

##  Simulation Waveform Analysis
To verify the physical layer timing, waveform analysis was conducted to trace the lifecycle of a transaction.

The image below demonstrates the sequence item generation and its translation by the Driver. It shows the UVM Sequence successfully generating a randomized payload, passing it to the Driver via the Sequencer's TLM port, and the Driver accurately toggling the AXI4-Lite physical pins (e.g., AWADDR, AWVALID, WDATA) in accordance with the strict handshake protocol.
(Note: Replace with your waveform screenshot showing the UVM sequence passing data to the driver and the resulting AXI pin toggles)


## Verification Results: 100% Functional Coverage
To ensure the robustness of the verification environment, a UVM Subscriber was implemented to collect functional coverage.

### Overcoming Coverage Holes
Initially, a coverage hole was detected because the random traffic accessed 4 physical registers, while the early RAL model only defined 2. The RAL model was immediately updated to perfectly match the DUT's physical memory map (ctrl_reg, status_reg, reg_2, reg_3).

Furthermore, a specific Out-of-Bound bin was added to the coverage model to strictly track the execution of the Error Injection scenarios. As a result, 100% Cross-Coverage (combining Read/Write operations across all valid and invalid address spaces) was successfully achieved and merged across all random regression seeds.

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
