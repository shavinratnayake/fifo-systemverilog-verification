# Synchronous FIFO Verification

SystemVerilog implementation and verification of a parameterized synchronous FIFO.

I built a class-based verification environment to test FIFO behavior using constrained-random stimulus, a reference-model scoreboard, SystemVerilog Assertions (SVA), and functional coverage.

During verification, the constrained-random regression exposed an RTL bug in the FIFO count logic. The scoreboard detected the resulting `empty` status mismatch, which was traced back to an incorrect count update during read-only operations.

## Design

The synchronous FIFO supports:

- Parameterized data width and depth
- Independent read and write control
- `full` and `empty` status flags
- Simultaneous read and write operations
- Overflow and underflow protection
- Read and write pointer wraparound
- Synchronous FIFO count tracking

## Verification Environment

The testbench uses a class-based SystemVerilog environment with a generator, driver, monitor, and scoreboard.

```text
Generator ──► Driver ──► DUT ──► Monitor ──► Scoreboard
                                                  │
                                            Reference Model
```

The generator produces constrained-random read and write operations. The driver applies the generated transactions to the FIFO through a SystemVerilog interface.

The monitor observes FIFO activity and sends transactions to the scoreboard. The scoreboard maintains an independent reference queue and compares the expected FIFO behavior against the DUT.

## Assertions

SVA properties check:

- Reset clears the FIFO
- `full` and `empty` are never asserted simultaneously
- Reading while empty does not advance the read pointer
- Writing while full does not advance the write pointer
- Accepted writes advance the write pointer
- Accepted reads advance the read pointer
- Write-only operations increment the FIFO count
- Read-only operations decrement the FIFO count
- Simultaneous reads and writes keep the count unchanged
- FIFO count remains within valid bounds

Additional cover properties verify that both the read and write pointers wrap around during the regression.

## Functional Coverage

Functional coverage tracks:

- Idle cycles
- Read operations
- Write operations
- Simultaneous read/write operations
- Empty and non-empty states
- Full and non-full states
- Underflow attempts
- Overflow attempts
- Operation × empty-state combinations
- Operation × full-state combinations

Final functional coverage:

```text
covergroup : 100.0% (26/26)
user       : 100.0% (2/2)
```

The two user coverage targets correspond to read-pointer and write-pointer wraparound.

## Verification Results

The final constrained-random regression completed with zero scoreboard failures:

```text
FIFO VERIFICATION TEST SUMMARY
Passed checks : 4479
Failed checks : 0
RESULT        : PASS
```

Final coverage included:

```text
Toggle coverage     : 99.5% (370/372)
Functional coverage : 100.0% (26/26)
Pointer wrap targets: 100.0% (2/2)
```

## Bug Found During Verification

Constrained-random testing exposed an error in the FIFO's read-only count update.

The incorrect RTL incremented the FIFO count during a read-only operation:

```systemverilog
2'b01: count <= count + 1'b1;
```

The scoreboard detected an `empty` status mismatch caused by the incorrect count. Debugging the failure isolated the issue to the count update logic, which was corrected to:

```systemverilog
2'b01: count <= count - 1'b1;
```

The full regression was rerun after the fix and completed with zero failures.

## Project Structure

```text
├── rtl/
│   └── sync_fifo.sv
└── tb/
    ├── fifo_driver.sv
    ├── fifo_generator.sv
    ├── fifo_if.sv
    ├── fifo_monitor.sv
    ├── fifo_scoreboard.sv
    ├── fifo_tb.sv
    └── fifo_transaction.sv
```

## Running with Verilator

Compile:

```bash
verilator --binary --coverage --assert -Wall -Wno-fatal \
  rtl/sync_fifo.sv \
  tb/fifo_if.sv \
  tb/fifo_transaction.sv \
  tb/fifo_generator.sv \
  tb/fifo_driver.sv \
  tb/fifo_monitor.sv \
  tb/fifo_scoreboard.sv \
  tb/fifo_tb.sv \
  --top-module fifo_tb
```

Run the regression:

```bash
./obj_dir/Vfifo_tb
```

View the coverage summary:

```bash
verilator_coverage --report summary coverage.dat
```

## Tools

SystemVerilog, SVA, constrained-random verification, functional coverage, Verilator, Git, Linux/WSL
