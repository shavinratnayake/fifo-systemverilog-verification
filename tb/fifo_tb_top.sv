`timescale 1ns/1ps

module fifo_tb_top;

    import uvm_pkg::*;
    import fifo_uvm_pkg::*;

    // Clock generation
    logic clk = 0;
    always #5 clk = ~clk;

    // Instantiate the FIFO interface
    fifo_if #(.DATA_WIDTH(8)) fifo_vif(clk);

    // Instantiate the FIFO DUT
    sync_fifo #(
        .DATA_WIDTH(8),
        .DEPTH(16)
    ) dut (
        .clk     (clk),
        .rst_n   (fifo_vif.rst_n),
        .wr_en   (fifo_vif.wr_en),
        .wr_data (fifo_vif.wr_data),
        .rd_en   (fifo_vif.rd_en),
        .rd_data (fifo_vif.rd_data),
        .full    (fifo_vif.full),
        .empty   (fifo_vif.empty)
    );

    fifo_assertions #(
        .DEPTH(16)
    ) fifo_assertions_inst (
        .clk(clk),
        .rst_n(fifo_vif.rst_n),
        .wr_en(fifo_vif.wr_en),
        .rd_en(fifo_vif.rd_en),
        .full(fifo_vif.full),
        .empty(fifo_vif.empty)
    );

    initial begin

        // Make the interface available to UVM components
        uvm_config_db#(virtual fifo_if)::set(
            null, "uvm_test_top.env.agent.*",
            "vif", fifo_vif
        );

        // Start the UVM test
        run_test("fifo_test");

    end

endmodule
