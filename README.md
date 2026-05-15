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

- sy_sequence (Directed-Random Read-After-Write): Generates random addresses and payloads to verify data persistence and memory integrity. Through unconstrained random address generation, this sequence dynamically proved two critical hardware behaviors in a single run:
  <img width="1798" height="750" alt="Image" src="https://github.com/user-attachments/assets/1c5a714c-bcb7-420f-b5ed-22dc75182cd5" />
  * **1. Out-of-Bounds Error Handling (Resp=10):** When invalid addresses (e.g., `0xFC`, `0xAC`) were randomly generated, the DUT correctly asserted a Slave Error (`Resp=10`). The Scoreboard intelligently identified and bypassed these invalid transactions (`Ignored Error Transaction`), preventing false simulation failures.
  * **2. Perfect Data Match (Resp=00):** When the sequence hit a valid register address (e.g., `0x00000008` in Loop 3), the DUT returned an OKAY response (`Resp=00`). The subsequent Read command to the exact same address resulted in a flawless `MATCH!` in the Scoreboard, proving absolute data integrity.

- vseq_rmw (Read-Modify-Write): A Virtual Sequence that orchestrates a complex transaction flow: reading an initial value from the DUT, modifying it dynamically in the sequence, and writing it back, proving the ability to handle dependent transactions.
  <img width="2458" height="598" alt="Image" src="https://github.com/user-attachments/assets/57f98b2c-b634-4271-a7d8-0643ee54e884" />

- sy_ral_sequence (Register Abstraction Layer): Utilizes uvm_reg_block and a custom Adapter to perform Frontdoor Write/Read operations. This demonstrates automatic physical address translation (e.g., ctrl_reg to 0x00) without hardcoding addresses in the sequence.
  <img width="2460" height="669" alt="Image" src="https://github.com/user-attachments/assets/c3e2eb92-69c1-4663-85c1-576a0b7605b4" />
  * **1. Frontdoor Write (Address Translation):** By simply calling `ctrl_reg.write()` without any physical address information, the RAL Adapter dynamically looked up the register map, translated it to `Addr=0x00`, and successfully passed the AXI transaction to the Driver. 
    *(Log: `[RAL_SEQ] Wrote 1 to CTRL_REG via RAL` ➔ `[DRV] Starting AXI Write Transaction`)*
  * **2. Frontdoor Read (Data Retrieval):** Similarly, issuing `status_reg.read()` automatically triggered an AXI Read burst to `0x04`. The Monitor captured the hardware response, and the RAL model seamlessly returned the exact read data back to the sequence. 
    *(Log: `[DRV] Read Done: Addr=00000004` ➔ `[RAL_SEQ] Read Data 00000000 from STATUS_REG via RAL`)*
  * **3. Autonomous Scoreboard Exception Handling:** When a Read command was issued to `STATUS_REG` (`0x04`) before any prior Write operation, the Scoreboard correctly identified the uninitialized state. Instead of triggering a false mismatch error, it intelligently logged a warning (`[SCB] Read from uninitialized address: 00000004`) and safely bypassed the comparison, proving the robust defensive logic of the reference model.

## SVA (SystemVerilog Assertions) Protocol Checking
To prove the robustness of the hardware monitors embedded in the axi4_lite_if, intentional timing and protocol violations were injected into the UVM Driver. The SVA successfully caught extreme corner-case bugs instantly, generating SVA FATAL errors without needing to inspect waveforms manually.

<img width="1582" height="534" alt="Image" src="https://github.com/user-attachments/assets/bb242088-dc09-4d1b-bb58-ddde74ccbca9" />
Intentional Bugs Caught:
1. Reset Rule Violation: WVALID was forced high during the active-low reset phase.
2. Payload Stability Violation: WDATA was mutated while waiting for WREADY to assert.


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
