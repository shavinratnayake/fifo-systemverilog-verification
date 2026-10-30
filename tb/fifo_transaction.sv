class fifo_transaction #(
    parameter int DATA_WIDTH = 8
);

// Stimulus
rand logic  wr_en;
rand logic  rd_en;
rand logic [DATA_WIDTH-1:0] data;

// DUT Observations
logic rst_n;
logic [DATA_WIDTH-1:0] rd_data;
logic full;
logic empty;

endclass
