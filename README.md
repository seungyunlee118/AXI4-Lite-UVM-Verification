# AXI4-Lite UVM Verification

## Project Overview
A scalable UVM (Universal Verification Methodology) testbench designed to validate an AXI4-Lite Slave IP. This project implements a robust verification architecture capable of high-coverage functional verification. Core features include a fully integrated Register Abstraction Layer (RAL) for abstracted register accesses, complex Virtual Sequences for scenarios like Read-Modify-Write and Error Injection, and cycle-accurate protocol monitoring using SystemVerilog Assertions (SVA). The environment is optimized with automated regression and coverage collection scripts for CI/CD integration.

## Architecture Block Diagram
<img width="599" height="327" alt="Image" src="https://github.com/user-attachments/assets/cffd6f8c-efda-4523-a649-96ad53f1344b" />

## Directory Structure
```text
├── rtl/       # Design Under Test (AXI4-Lite Slave)
├── src/       # UVM Components (Agent, Monitor, Scoreboard, RAL, etc.)
├── tb/        # Testbench Top and AXI Interface (with SVA)
├── sim/       # Simulation working directory (Makefile, logs, coverage databases)
├── scripts/   # Automation scripts and parsers
└── docs/      # Waveforms, diagrams, and coverage reports
```

##  Key Verification Scenarios & Sequences
To thoroughly verify the DUT, various UVM sequences were implemented ranging from basic random traffic to highly targeted corner-case scenarios.

- sy_sequence (Directed-Random Read-After-Write): Generates a random valid address, writes a randomized payload, and immediately issues a read command to the exact same address to verify data persistence and memory integrity.
  <img width="895" height="596" alt="Image" src="https://github.com/user-attachments/assets/c884a818-226a-4d06-b032-7e5f0d72fa61" />

- vseq_rmw (Read-Modify-Write): A Virtual Sequence that orchestrates a complex transaction flow: reading an initial value from the DUT, modifying it dynamically in the sequence, and writing it back, proving the ability to handle dependent transactions.
  <img width="2458" height="828" alt="Image" src="https://github.com/user-attachments/assets/cd2f5f45-2297-47a4-9ab9-c4b97b97b887" />

- sy_ral_sequence (Register Abstraction Layer): Utilizes uvm_reg_block and a custom Adapter to perform Frontdoor Write/Read operations. This demonstrates automatic physical address translation (e.g., ctrl_reg to 0x00) without hardcoding addresses in the sequence.
  <img width="2460" height="858" alt="Image" src="https://github.com/user-attachments/assets/827bf187-c54a-4b0b-a503-63b518b595ef" />


## SVA (SystemVerilog Assertions) Protocol Checking
To prove the robustness of the hardware monitors embedded in the axi4_lite_if, intentional timing and protocol violations were injected into the UVM Driver. The SVA successfully caught extreme corner-case bugs instantly, generating SVA FATAL errors without needing to inspect waveforms manually.

Intentional Bugs Caught:
1. Reset Rule Violation: WVALID was forced high during the active-low reset phase.
2. Payload Stability Violation: WDATA was mutated while waiting for WREADY to assert.

<img width="1582" height="534" alt="Image" src="https://github.com/user-attachments/assets/8ca80031-5b8e-4aeb-8bf6-9fe6d3997290" />

## Simulation Results & Log Analysis
The testbench utilizes an advanced Scoreboard with an associative array-based Reference Model to verify data integrity and handle error codes autonomously.

### 1. Data Match & Integrity Verification
During the full sweep scenario, the Scoreboard dynamically stored expected values upon Write operations and flawlessly matched them against actual Read data.
```text
SCB] Stored Expected: Addr=00000008, Data=33333333
[MON] Captured WRITE: Addr=00000008, Data=33333333, Resp=00
[DRV] Starting AXI Read Transaction...
[SCB] MATCH! Addr=00000008, Data=33333333
```
### 2. Error Injection (Corner Case Handling)
An out-of-bound address (0xFFFF0000) was intentionally injected. The DUT correctly returned a Slave Error (Resp=10), and the Scoreboard intelligently ignored the invalid data to prevent false failures.

```text
[VSEQ_ERR] Sent Invalid Write Access to Address 0xFFFF0000
[MON] Captured WRITE: Addr=ffff0000, Data=deaddead, Resp=10
[SCB] Ignored Error Transaction: Addr=ffff0000, Resp=10
```
<img width="961" height="225" alt="Image" src="https://github.com/user-attachments/assets/a81ca2fd-b36c-4928-9cb7-9ec1c412c962" />

### 3. 100% Functional Coverage
By simulating both valid address spaces (0x00 to 0x0C) and invalid/error-inducing address spaces, a perfect 100% Cross-Coverage (combining Read/Write commands with specific address bins) was achieved and validated via the UVM Subscriber.
<img width="2488" height="232" alt="Image" src="https://github.com/user-attachments/assets/d54ea37d-d07b-4112-a594-972b564c1a04" />


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
