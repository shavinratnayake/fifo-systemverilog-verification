class fifo_scoreboard #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH = 16
);
    // Mailbox from monitor to scoreboard
    mailbox #(fifo_transaction #(DATA_WIDTH)) mon2scb;

    // Reference model of FIFO
    logic [DATA_WIDTH-1:0] reference_queue[$];

    // Expected data from an accepted read
    logic [DATA_WIDTH-1:0] expected_rd_data;

    // Indicates that a read result needs to be checked.
    logic read_pending;

    // Test result counters
    int passed;
    int failed;

    function new (
        mailbox #(fifo_transaction #(DATA_WIDTH)) mon2scb_in
    );

        this.mon2scb = mon2scb_in;

        passed = 0;
        failed = 0;
        read_pending = 1'b0;

    endfunction


    
    task run();

        fifo_transaction #(DATA_WIDTH) trans;

        logic expected_empty;
        logic expected_full;

        forever begin

            mon2scb.get(trans);

            // Reset refernce model when DUT is in reset
            if (!trans.rst_n) begin
                reference_queue.delete();
                read_pending = 1'b0;

                continue;
            end

            // Determine expected FIFO status from reference model
            expected_empty = (reference_queue.size() === 0);
            expected_full = (reference_queue.size() === DEPTH);

            // Check DUT empty flag
            if (trans.empty === expected_empty) begin
                passed++;
            end
            else begin

                $error(
                    "FAIL: EMPTY mismatch. Expected = %0b, Actual = %0b",
                    expected_empty,
                    trans.empty
                );

                failed++;
            end

            // Check DUT full flag
            if (trans.full === expected_full) begin
                passed++;
            end
            else begin

                $error(
                    "FAIL: FULL mismatch. Expected = %0b, Actual = %0b",
                    expected_full,
                    trans.full
                );

                failed++;
            end
            

            if (read_pending) begin
                if (trans.rd_data === expected_rd_data) begin
                    $display(
                        "PASS: Read data = %h",
                        trans.rd_data
                    );
                    passed ++;
                end
                else begin
                    $error(
                        "FAIL: Expected read data = %h, Actual = %h",
                        expected_rd_data,
                        trans.rd_data
                    );
                    failed ++;
                end
                read_pending = 1'b0;
            end
            
            // Read is enabled and FIFO is not empty
            if (trans.rd_en && !expected_empty) begin
                expected_rd_data = reference_queue.pop_front();
                read_pending = 1'b1;
            end

            // Write is enabled and FIFO is not full
            if (trans.wr_en && !expected_full) begin
                reference_queue.push_back(trans.data);

            end
        end

    endtask



    function void report();

        $display("========================================");
        $display("FIFO VERIFICATION TEST SUMMARY");
        $display("Passed checks : %0d", passed);
        $display("Failed checks : %0d", failed);

        if (failed == 0)
            $display("RESULT        : PASS");
        else
            $display("RESULT        : FAIL");

        $display("========================================");

    endfunction

endclass
