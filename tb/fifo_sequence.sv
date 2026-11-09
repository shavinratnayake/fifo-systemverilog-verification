class fifo_sequence extends uvm_sequence #(fifo_transaction);

    `uvm_object_utils(fifo_sequence)

    function new(string name = "fifo_sequence");
        super.new(name);
    endfunction

    task body();

        fifo_transaction tx;

        repeat (100) begin

            tx = fifo_transaction::type_id::create("tx");

            start_item(tx);

            if (!tx.randomize())
                `uvm_fatal("RAND", "Transaction randomization failed")

            finish_item(tx);

        end

    endtask

endclass


class fifo_fill_sequence extends uvm_sequence #(fifo_transaction);

    `uvm_object_utils(fifo_fill_sequence)

    function new(string name = "fifo_fill_sequence");
        super.new(name);
    endfunction

    task body();
        fifo_transaction tx;

        // Fill the FIFO with 16 writes
        for (int i = 0; i < 16; i++) begin
            tx = fifo_transaction::type_id::create("write_tx");

            start_item(tx);

            tx.wr_en   = 1'b1;
            tx.rd_en   = 1'b0;
            tx.wr_data = 8'(i);

            finish_item(tx);
        end

        // Attempt one additional write while full
        tx = fifo_transaction::type_id::create("overflow_tx");

        start_item(tx);

        tx.wr_en   = 1'b1;
        tx.rd_en   = 1'b0;
        tx.wr_data = 8'hFF;

        finish_item(tx);

    endtask

endclass


class fifo_drain_sequence extends uvm_sequence #(fifo_transaction);

    `uvm_object_utils(fifo_drain_sequence)

    function new(string name = "fifo_drain_sequence");
        super.new(name);
    endfunction

    task body();

        fifo_transaction tx;

        for (int i = 0; i < 16; i++) begin
            tx = fifo_transaction::type_id::create("read_tx");

            start_item(tx);

            tx.wr_en    = 1'b0;
            tx.rd_en    = 1'b1;
            tx.wr_data  = 8'h00;

            finish_item(tx);
        end

        // Attempt one additional read while empty
        tx = fifo_transaction::type_id::create("underflow_tx");

        start_item(tx);

        tx.wr_en    = 1'b0;
        tx.rd_en    = 1'b1;
        tx.wr_data  = 8'h00;

        finish_item(tx);

    endtask

endclass


class fifo_simultaneous_sequence extends uvm_sequence #(fifo_transaction);

    `uvm_object_utils(fifo_simultaneous_sequence)

    function new(string name = "fifo_simultaneous_sequence");
        super.new(name);
    endfunction

    task body();

        fifo_transaction tx;

        // Write one entry so FIFO is not empty
        tx = fifo_transaction::type_id::create("initial_write");

        start_item(tx);

        tx.wr_en    = 1'b1;
        tx.rd_en    = 1'b0;
        tx.wr_data  = 8'hA5;

        finish_item(tx);

        // write/read 20 requests simultaneously
        for (int i = 0; i < 20; i++) begin
            tx = fifo_transaction::type_id::create("simultaneous_tx");

            start_item(tx);

            tx.wr_en    = 1'b1;
            tx.rd_en    = 1'b1;
            tx.wr_data  = 8'(i);

            finish_item(tx);
        end
    
    endtask

endclass




