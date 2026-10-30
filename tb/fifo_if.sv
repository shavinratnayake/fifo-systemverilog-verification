interface fifo_if #(
    parameter int DATA_WIDTH = 8
)(
    input logic clk

);

    logic   rst_n;
    logic   wr_en;
    logic [DATA_WIDTH-1:0] wr_data;
    logic   rd_en;
    logic [DATA_WIDTH-1:0] rd_data;
    logic   full;
    logic   empty;

    clocking drv_cb @(posedge clk);
        output rst_n;
        output wr_en;
        output wr_data;
        output rd_en;

        input rd_data;
        input full;
        input empty;

    endclocking


    clocking mon_cb @(posedge clk);
        default input #1step;

        input rst_n;
        input wr_en;
        input wr_data;
        input rd_en;
        input rd_data;
        input full;
        input empty;

    endclocking

    modport DRIVER (
        clocking drv_cb
    );

    modport MONITOR (
        clocking mon_cb
    );

endinterface

