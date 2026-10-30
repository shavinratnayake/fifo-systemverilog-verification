module fifo_tb;

    parameter int DATA_WIDTH = 8;
    parameter int DEPTH = 16;
    parameter int NUM_TRANSACTIONS = 1000;
    parameter int CLOCK_PERIOD = 10;

    localparam int PTR_WIDTH = $clog2(DEPTH);

    // Clock 
    logic clk;

    // FIFO interface
    fifo_if #(DATA_WIDTH) fifo_interface(clk);


    // Mailboxes 
    mailbox #(fifo_transaction #(DATA_WIDTH)) gen2drv;
    mailbox #(fifo_transaction #(DATA_WIDTH)) mon2scb;

    // Testbench components
    fifo_generator #(
        DATA_WIDTH
    ) generator;

    fifo_driver #(
        DATA_WIDTH
    ) driver;

    fifo_monitor #(
        DATA_WIDTH
    ) monitor;

    fifo_scoreboard #(
        DATA_WIDTH
    ) scoreboard;

    // DUT
    sync_fifo #(
        .DATA_WIDTH (DATA_WIDTH),
        .DEPTH (DEPTH)
    ) dut (
        .clk (clk),
        .rst_n (fifo_interface.rst_n),

        .wr_en (fifo_interface.wr_en),
        .wr_data (fifo_interface.wr_data),

        .rd_en (fifo_interface.rd_en),
        .rd_data (fifo_interface.rd_data),

        .full (fifo_interface.full),
        .empty (fifo_interface.empty)
    );

    // Clock generation
    initial begin
        clk = 1'b0;
        forever  #(CLOCK_PERIOD / 2) clk = ~clk;
    end



    // Assertions
    property p_reset_clears_fifo;
        @(posedge clk)
        !fifo_interface.rst_n |=> 
        (fifo_interface.empty && !fifo_interface.full);
    endproperty

    ap_reset_clears_fifo:
        assert property (p_reset_clears_fifo)
        else $error("FIFO reset failed: FIFO is not empty after reset");


    property p_full_and_empty_not_both_high;
        @(posedge clk)
        !(fifo_interface.full && fifo_interface.empty);
    endproperty

    ap_full_and_empty_not_both_high:
        assert property (p_full_and_empty_not_both_high)
        else $error("FIFO error: full and empty are both asserted");

    
    property p_read_while_empty_no_pointer_change;
        @(posedge clk)
        (fifo_interface.rd_en && fifo_interface.empty) |=> $stable(dut.rd_ptr);
    endproperty

    ap_read_while_empty_no_pointer_change:
        assert property (p_read_while_empty_no_pointer_change)
        else $error("FIFO underflow error: read pointer changed while empty");


    property p_write_while_full_no_pointer_change;
        @(posedge clk)
        (fifo_interface.wr_en && fifo_interface.full) |=> $stable(dut.wr_ptr);
    endproperty

    ap_write_while_full_no_pointer_change:
        assert property (p_write_while_full_no_pointer_change)
        else $error("FIFO overflow error: write pointer changed while full");

    
    property p_accepted_write_advances_pointer;
        @(posedge clk)
        (fifo_interface.wr_en && !fifo_interface.full) 
        |=> 
        (
            ($past(dut.wr_ptr) == PTR_WIDTH'(DEPTH - 1))
            ? (dut.wr_ptr == '0)
            : (dut.wr_ptr == $past(dut.wr_ptr) + 1'b1)
        );
    endproperty

    ap_accepted_write_advances_pointer:
        assert property (p_accepted_write_advances_pointer)
        else $error("FIFO write error: write pointer did not advance correctly");
    

    property p_accepted_read_advances_pointer;
        @(posedge clk)
        (fifo_interface.rd_en && !fifo_interface.empty)
        |=>
        (
            ($past(dut.rd_ptr) == PTR_WIDTH'(DEPTH - 1))
            ? (dut.rd_ptr == '0)
            : (dut.rd_ptr == $past(dut.rd_ptr) + 1'b1)
        );
    endproperty
    
    ap_accepted_read_advances_pointer:
        assert property (p_accepted_read_advances_pointer)
        else $error("FIFO read error: read pointer did not advance correctly");


    property p_write_only_increments_count;
        @(posedge clk)
        ((fifo_interface.wr_en && !fifo_interface.full) && !(fifo_interface.rd_en && !fifo_interface.empty))
        |=> 
        (dut.count == $past(dut.count) + 1'b1);
    endproperty

    ap_write_only_increments_count:
        assert property (p_write_only_increments_count)
        else $error("FIFO count error: count did not increment after write-only operation");


    property p_read_only_decrements_count;
        @(posedge clk)
        ((fifo_interface.rd_en && !fifo_interface.empty) && !(fifo_interface.wr_en && !fifo_interface.full))
        |=>
        (dut.count == $past(dut.count) - 1'b1);
    endproperty

    ap_read_only_decrements_count:
        assert property (p_read_only_decrements_count)
        else $error("FIFO count error: count did not decrement after read-only operation");

    
    property p_simultaneous_read_write_keeps_count;
        @(posedge clk)
        ((fifo_interface.rd_en && !fifo_interface.empty) && (fifo_interface.wr_en && !fifo_interface.full))
        |=>
        $stable(dut.count);
    endproperty

    ap_simultaneous_read_write_keeps_count:
        assert property (p_simultaneous_read_write_keeps_count)
        else $error("FIFO count error: count changed during simultaneous read/write");

    
    property p_count_within_bounds;
        @(posedge clk)
        dut.count <= (PTR_WIDTH + 1)'(DEPTH);
    endproperty

    ap_count_within_bounds:
        assert property (p_count_within_bounds)
        else $error("FIFO count error: count exceded FIFO depth");


    property p_write_pointer_wrap;
        @(posedge clk)
        ($past(dut.wr_ptr) == PTR_WIDTH'(DEPTH - 1)) &&
        (dut.wr_ptr == '0);
    endproperty

    cp_write_pointer_wrap:
        cover property (p_write_pointer_wrap);


    property p_read_pointer_wrap;
        @(posedge clk)
        ($past(dut.rd_ptr) == PTR_WIDTH'(DEPTH - 1)) &&
        (dut.rd_ptr == '0);
    endproperty

    cp_p_read_pointer_wrap:
        cover property (p_read_pointer_wrap);

    

    // Main test 
    initial begin

        // Create mailboxes 
        gen2drv = new();
        mon2scb = new();

        // Create testbench components
        generator = new(
            gen2drv,
            NUM_TRANSACTIONS
        );

        driver = new(
            gen2drv,
            fifo_interface,
            NUM_TRANSACTIONS
        );

        monitor = new(
            mon2scb,
            fifo_interface
        );

        scoreboard = new(
            mon2scb
        );

        // Reset DUT
        driver.reset();

        // Generate randomized transactions 
        generator.run();

        // Start monitor and scoreboard
        fork : background_processes

            monitor.run();
            scoreboard.run();
        
        join_none

        // Drive all generated transactions 
        driver.run();

        // Allow final monitored results to reach the scoreboard
        repeat (2)@(posedge clk);

        // Print final results
        scoreboard.report();

        // Stop background_processes
        disable background_processes;

        $finish;
    end
endmodule

