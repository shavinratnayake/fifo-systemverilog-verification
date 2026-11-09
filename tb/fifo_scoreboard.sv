class fifo_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(fifo_scoreboard)

    uvm_analysis_imp #(fifo_transaction, fifo_scoreboard) analysis_export;

    bit [7:0] expected_queue[$];
    bit [7:0] expected_rd_data = '0;
    bit rd_data_valid = 0;

    int tests_passed = 0;
    int tests_failed = 0;
    bit reset_seen = 0;

    int write_count = 0;
    int read_count = 0;
    int simultaneous_count = 0;
    int full_count = 0;
    int empty_count = 0;

    function new(string name = "fifo_scoreboard",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_export = new("analysis_export", this);
    endfunction

    


function void write(fifo_transaction tx);

    bit expected_full;
    bit expected_empty;
    bit accepted_write;
    bit accepted_read;

    // Wait until the first reset edge has been modeled
    if (!reset_seen) begin

        if (!tx.rst_n) begin
            expected_queue.delete();
            expected_rd_data = '0;
            rd_data_valid = 1;
            reset_seen = 1;
        end

        return;
    end

    // Calculate expected FIFO flags before this clock edge
    expected_empty = (expected_queue.size() == 0);
    expected_full  = (expected_queue.size() == 16);

    // Check EMPTY flag
    if (tx.empty !== expected_empty) begin
        `uvm_error("FIFO_SB",
            $sformatf("EMPTY mismatch: expected=%0b actual=%0b",
                      expected_empty, tx.empty))
        tests_failed++;
    end
    else
        tests_passed++;

    // Check FULL flag
    if (tx.full !== expected_full) begin
        `uvm_error("FIFO_SB",
            $sformatf("FULL mismatch: expected=%0b actual=%0b",
                      expected_full, tx.full))
        tests_failed++;
    end
    else
        tests_passed++;

    // Check read data against the previous cycle's result
    if (rd_data_valid) begin
        if (tx.rd_data !== expected_rd_data) begin
            `uvm_error("FIFO_SB",
                $sformatf("Read data mismatch: expected=%h actual=%h",
                          expected_rd_data, tx.rd_data))
            tests_failed++;
        end
        else
            tests_passed++;
    end

    // Model synchronous reset at this clock edge
    if (!tx.rst_n) begin
        expected_queue.delete();
        expected_rd_data = '0;
        rd_data_valid = 1;
        return;
    end

    // Determine accepted operations using pre-edge flags
    accepted_write = tx.wr_en && !expected_full;
    accepted_read  = tx.rd_en && !expected_empty;

    // Transaction statistics
    if (accepted_write)
        write_count++;

    if (accepted_read)
        read_count++;

    if (tx.wr_en && tx.rd_en)
        simultaneous_count++;

    if (expected_full)
        full_count++;

    if (expected_empty)
        empty_count++;

    // Update reference model
    // Read first so simultaneous operations use old data
    if (accepted_read)
        expected_rd_data = expected_queue.pop_front();

    if (accepted_write)
        expected_queue.push_back(tx.wr_data);

    rd_data_valid = 1;

endfunction


function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    // Display scoreboard results
    `uvm_info("FIFO_SB",
        $sformatf(
            "Scoreboard Results: PASSED=%0d FAILED=%0d",
            tests_passed,
            tests_failed
        ),
        UVM_LOW
    )

    // Display FIFO transaction statistics
    `uvm_info("FIFO_STATS",
        $sformatf(
            "Writes=%0d Reads=%0d Simultaneous=%0d FullCycles=%0d EmptyCycles=%0d",
            write_count,
            read_count,
            simultaneous_count,
            full_count,
            empty_count
        ),
        UVM_LOW
    )

    // Ensure the scoreboard actually performed checks
    if (tests_passed == 0)
        `uvm_error("FIFO_SB", "No scoreboard checks executed!")

    // Report verification failure
    if (tests_failed > 0)
        `uvm_error("FIFO_SB", "FIFO verification failed!")

endfunction


endclass
