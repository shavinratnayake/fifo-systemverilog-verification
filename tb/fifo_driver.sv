class fifo_driver extends uvm_driver #(fifo_transaction);

    `uvm_component_utils(fifo_driver)

    virtual fifo_if vif;

    function new(string name = "fifo_driver",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual fifo_if)::get(
                this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Virtual interface not found")
    endfunction

    

    
task run_phase(uvm_phase phase);

    fifo_transaction tx;

    // Initialize interface
    vif.rst_n   = 0;
    vif.wr_en   = 0;
    vif.rd_en   = 0;
    vif.wr_data = '0;

    // Hold reset for two cycles
    repeat (2) @(posedge vif.clk);

    @(negedge vif.clk);
    vif.rst_n = 1;

    forever begin

        // Obtain the next transaction if available
        seq_item_port.try_next_item(tx);

        if (tx != null) begin

            // Drive transaction on falling edge
            vif.wr_en   = tx.wr_en;
            vif.rd_en   = tx.rd_en;
            vif.wr_data = tx.wr_data;

            // Complete transaction after DUT samples it
            @(posedge vif.clk);
            seq_item_port.item_done();

        end
        else begin

            // No transaction available: drive idle
            vif.wr_en   = 0;
            vif.rd_en   = 0;
            vif.wr_data = '0;

            @(posedge vif.clk);

        end

        // Advance to the next driving edge
        @(negedge vif.clk);

    end

endtask



endclass
