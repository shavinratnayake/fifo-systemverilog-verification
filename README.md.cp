# Synchronous FIFO Verification — SystemVerilog/UVM

A SystemVerilog UVM verification environment for an 8-bit, 16-entry synchronous FIFO.

## Verification Architecture

- UVM transaction, sequences, and sequencer
- UVM driver and monitor
- UVM agent and environment
- Self-checking reference-model scoreboard
- Functional coverage collector
- Five SystemVerilog Assertions (SVA)

## Verification Scenarios

- FIFO fill and drain
- Overflow and underflow attempts
- Simultaneous read/write operations
- Back-to-back transactions
- FIFO full and empty flag checking
- Read-data ordering and integrity
- Read/write pointer wraparound

## Latest Simulation Results

| Metric | Result |
|---|---|
| Scoreboard checks passed | 171 |
| Scoreboard failures | 0 |
| Functional coverage | 85.71% |
| Accepted writes | 37 |
| Accepted reads | 36 |
| Simultaneous read/write requests | 20 |
| Back-to-back active-cycle pairs | 54 |
| SVA properties | 5 |
| Reported assertion violations | 0 |

Results are from the directed UVM simulation. Functional coverage reflects the currently defined coverage model.

## Tools

- SystemVerilog
- Accellera UVM 2020.3.1
- Verilator 5.051 development build
- Ubuntu Linux / WSL

## Build and Run

The project requires Verilator with UVM support and an installed Accellera UVM library.

```bash
export UVM_HOME="$HOME/uvm-core"

verilator --binary --timing --assert --coverage -Wno-fatal -j 4 \
  +define+UVM_NO_DPI \
  +incdir+$UVM_HOME/src \
  +incdir+tb \
  $UVM_HOME/src/uvm_pkg.sv \
  tb/fifo_if.sv \
  tb/fifo_uvm_pkg.sv \
  rtl/sync_fifo.sv \
  tb/fifo_assertions.sv \
  tb/fifo_tb_top.sv \
  --top-module fifo_tb_top

./obj_dir/Vfifo_tb_top
