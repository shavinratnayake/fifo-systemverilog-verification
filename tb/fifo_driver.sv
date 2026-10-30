class fifo_driver #(
    parameter int DATA_WIDTH = 8
);

    mailbox #(fifo_transaction #(DATA_WIDTH)) gen2drv;

    virtual fifo_if #(DATA_WIDTH).DRIVER vif;

    int num_transactions;

    function new(
        mailbox #(fifo_transaction #(DATA_WIDTH)) gen2drv_in, 
        virtual fifo_if #(DATA_WIDTH).DRIVER vif_in,
        int num_transactions_in
    );
        this.gen2drv = gen2drv_in;
        this.vif = vif_in;
        this.num_transactions = num_transactions_in;
    endfunction

    task reset();

        vif.drv_cb.rst_n <= 1'b0;
        vif.drv_cb.wr_en <= 1'b0;
        vif.drv_cb.wr_data <= '0;
        vif.drv_cb.rd_en <= 1'b0;

        repeat (2) @(vif.drv_cb);

        vif.drv_cb.rst_n <= 1'b1;

        repeat (2) @(vif.drv_cb);
    
    endtask

    task run();

        fifo_transaction #(DATA_WIDTH) trans;

        repeat (num_transactions) begin

            gen2drv.get(trans);

            vif.drv_cb.wr_en <= trans.wr_en;
            vif.drv_cb.rd_en <= trans.rd_en;
            vif.drv_cb.wr_data <= trans.data;
            
            @(vif.drv_cb);

            vif.drv_cb.wr_en <= 1'b0;
            vif.drv_cb.rd_en <= 1'b0;

            @(vif.drv_cb);
        
        end

    endtask

endclass
