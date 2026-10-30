class fifo_generator #(
    parameter int DATA_WIDTH = 8
);

    mailbox #(fifo_transaction #(DATA_WIDTH)) gen2drv;

    int NUM_TRANSACTIONS;

    function new(
        mailbox #(fifo_transaction #(DATA_WIDTH)) gen2drv_in,
        int NUM_TRANSACTIONS_IN
    );
        this.gen2drv = gen2drv_in;
        this.NUM_TRANSACTIONS = NUM_TRANSACTIONS_IN;
    endfunction

    task run();

        fifo_transaction #(DATA_WIDTH) trans;

        repeat (NUM_TRANSACTIONS) begin

            trans = new();

            if(!trans.randomize()) begin
                $error("FIFO transaction randomization failed");
            end

            gen2drv.put(trans);
        end
    endtask

endclass



