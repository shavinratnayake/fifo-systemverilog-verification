class fifo_monitor #(
    parameter int DATA_WIDTH = 8
    );

    mailbox #(fifo_transaction #(DATA_WIDTH)) mon2scb;

    virtual fifo_if #(DATA_WIDTH).MONITOR vif;

    covergroup fifo_cg;

        operation_cp: coverpoint {vif.mon_cb.wr_en, vif.mon_cb.rd_en} {
            bins idle   = {2'b00};
            bins read   = {2'b01};
            bins write  = {2'b10};
            bins read_write = {2'b11};
        }

        empty_cp: coverpoint vif.mon_cb.empty {
            bins not_empty  = {1'b0};
            bins empty  = {1'b1};
        }

        full_cp: coverpoint vif.mon_cb.full {
            bins not_full   = {1'b0};
            bins full   = {1'b1};
        }

        underflow_cp: coverpoint (vif.mon_cb.rd_en && vif.mon_cb.empty){
            bins underflow_attempt  = {1'b1};
        }

        overflow_cp: coverpoint (vif.mon_cb.wr_en && vif.mon_cb.full){
            bins overflow_attempt   = {1'b1};
        }

        operation_empty_cross: cross operation_cp, empty_cp;

        operation_full_cross: cross operation_cp, full_cp;

    endgroup

    function new(
        mailbox #(fifo_transaction #(DATA_WIDTH)) mon2scb_in,
        virtual fifo_if #(DATA_WIDTH).MONITOR vif_in
    );

        this.mon2scb = mon2scb_in;
        this.vif = vif_in;

        fifo_cg = new();
    endfunction

    task run();

        fifo_transaction #(DATA_WIDTH) trans;

        forever begin

            @(vif.mon_cb);

            trans = new();

            trans.wr_en = vif.mon_cb.wr_en;
            trans.rd_en = vif.mon_cb.rd_en;
            trans.data = vif.mon_cb.wr_data;

            trans.rst_n = vif.mon_cb.rst_n;
            trans.rd_data = vif.mon_cb.rd_data;
            trans.full = vif.mon_cb.full;
            trans.empty = vif.mon_cb.empty;

            fifo_cg.sample();

            mon2scb.put(trans);

        end

    endtask

endclass
