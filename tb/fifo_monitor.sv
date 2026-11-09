class fifo_monitor extends uvm_monitor;

    `uvm_component_utils(fifo_monitor)

    virtual fifo_if vif;

    uvm_analysis_port #(fifo_transaction) ap;

    function new(string name = "fifo_monitor",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap = new("ap", this);

        if (!uvm_config_db#(virtual fifo_if)::get(
                this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);

        fifo_transaction tx;

        forever begin

            @(vif.mon_cb);

            tx = fifo_transaction::type_id::create("tx");

            tx.rst_n   = vif.mon_cb.rst_n;
            tx.wr_en   = vif.mon_cb.wr_en;
            tx.wr_data = vif.mon_cb.wr_data;
            tx.rd_en   = vif.mon_cb.rd_en;

            tx.rd_data = vif.mon_cb.rd_data;
            tx.full    = vif.mon_cb.full;
            tx.empty   = vif.mon_cb.empty;

            ap.write(tx);

        end

    endtask

endclass
