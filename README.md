# FIFO — SystemVerilog/UVM Verification

## Overview

This project verifies an 8-bit, 16-entry synchronous FIFO using a UVM-based SystemVerilog testbench.

The verification environment includes directed test sequences, a self-checking reference-model scoreboard, SystemVerilog Assertions (SVA), and functional coverage to verify FIFO data integrity and control behavior.

## Design

The FIFO supports synchronous read and write operations, with control logic for full and empty conditions.

Key functionality includes:

- 8-bit data width and 16-entry depth
- FIFO data ordering (first-in, first-out)
- Full and empty status detection
- Simultaneous read and write operations
- Read and write pointer wraparound

## Verification Environment

The testbench uses UVM components to separate stimulus generation, signal driving, monitoring, and result checking.

- **Sequences and Sequencer:** Generate and schedule FIFO read/write transactions.
- **Driver:** Applies transactions to the FIFO interface.
- **Monitor:** Captures DUT activity for checking and coverage.
- **Agent and Environment:** Organize and connect the verification components.
- **Scoreboard:** Uses a reference queue to check data ordering, read/write behavior, and FIFO status.

## Test Scenarios

Directed sequences exercise:

- Basic read and write operations
- FIFO fill and drain
- Overflow and underflow attempts
- Back-to-back transactions
- Simultaneous read/write operations
- Pointer wraparound

## Assertions and Coverage

Five SystemVerilog Assertions check FIFO control behavior during simulation.

Functional coverage tracks FIFO operations, status conditions, and cross coverage between them to measure which scenarios have been exercised.

## Verification Results

The testbench was run using Verilator with Accellera UVM.

| Metric | Result |
|---|---|
| Scoreboard checks | 171 passed |
| Failed checks | 0 |
| Functional coverage | 85.71% |
| Simulation result | PASS |

The reported results are from directed UVM tests. A randomized sequence is defined but is not included in the current verification run.

## Tools

- SystemVerilog / UVM 
- Verilator 
- Git / GitHub


