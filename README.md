# FIFO — SystemVerilog/UVM Verification

## Overview

This project implements and verifies an 8-bit, 16-entry synchronous FIFO using SystemVerilog and the Universal Verification Methodology (UVM).

The testbench uses directed UVM sequences, a self-checking reference-model scoreboard, SystemVerilog Assertions (SVA), and functional coverage to verify FIFO data integrity and control behavior.

## Design

The FIFO uses read and write pointers to manage data stored in a 16-entry buffer.

Key functionality includes:

- 8-bit data width and 16-entry depth
- Synchronous read and write operations
- First-in, first-out data ordering
- Full and empty status detection
- Simultaneous read and write operations
- Read and write pointer wraparound

## Verification Architecture

The verification environment is built using UVM. Separate components handle stimulus generation, driving DUT inputs, monitoring outputs, and checking results.

The main components are:

- **Sequence Item:** Defines FIFO read/write transactions and their associated data.
- **Sequences:** Generate directed transactions to exercise different FIFO conditions.
- **Sequencer:** Supplies transactions from sequences to the driver.
- **Driver:** Applies read and write requests to the DUT through the FIFO interface.
- **Monitor:** Captures FIFO operations and status signals for checking and coverage.
- **Agent:** Groups the sequencer, driver, and monitor.
- **Environment:** Instantiates and connects the verification components.
- **Scoreboard:** Maintains a reference queue to verify FIFO data ordering, read/write behavior, and status conditions.
- **UVM Test:** Configures the environment and executes the verification sequences.

The environment uses UVM transaction-level communication to coordinate stimulus and checking.

### Test Stimulus

Directed UVM sequences exercise:

- Basic read and write operations
- FIFO fill and drain
- Overflow and underflow attempts
- Back-to-back transactions
- Simultaneous read/write operations
- Pointer wraparound

A randomized sequence is also defined but is not included in the reported simulation results.

## SystemVerilog Assertions

Five SystemVerilog Assertions are implemented to check FIFO control behavior during simulation.

These assertions provide additional checks alongside the reference-model scoreboard.

## Functional Coverage

Functional coverage is collected to track FIFO operations and status conditions.

The coverage model includes:

- Read and write operations
- FIFO full and empty conditions
- Cross coverage between FIFO operations and status conditions

Coverage is used to identify scenarios that have been exercised and areas requiring additional verification.

## Verification Results

The simulation was run using Verilator with Accellera UVM.

| Metric | Result |
|---|---|
| Data width | 8 bits |
| FIFO depth | 16 entries |
| Scoreboard checks passed | 171 |
| Scoreboard checks failed | 0 |
| Functional coverage | 85.71% |
| Simulation result | PASS |

All 171 scoreboard checks passed with no reported failures.

Functional coverage reached 85.71% across the defined coverage model.

## Implementation Notes

- The testbench uses standard UVM components and transaction-level communication.
- Directed sequences exercise normal FIFO operation and boundary conditions.
- A reference-model scoreboard checks expected behavior against DUT activity.
- Five assertions provide additional FIFO control checks.
- Functional and cross coverage are collected during simulation.
- Constrained-random testing is planned but was not executed in the reported run.

## Tools

- SystemVerilog
- Accellera UVM 2020.3.1
- Verilator 5.051 (development build)
- Git / GitHub
