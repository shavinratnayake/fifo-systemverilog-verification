class fifo_coverage extends uvm_subscriber #(fifo_transaction);

    `uvm_component_utils(fifo_coverage)

    bit sample_wr_en;
    bit sample_rd_en;
    bit sample_full;
    bit sample_empty;

    int back_to_back_count = 0;
    bit previous_active = 0;

    covergroup fifo_cg;

        cp_write: coverpoint sample_wr_en;
        cp_read: coverpoint sample_rd_en;
        cp_full: coverpoint sample_full;
        cp_empty: coverpoint sample_empty;

        cp_operations: coverpoint {sample_wr_en, sample_rd_en} {
            bins idle           = {2'b00};
            bins write_only     = {2'b01};
            bins read_only      = {2'b10};
            bins simulataneous  = {2'b11}; 
        }

        operation_x_full: cross cp_operations, cp_full;
        operation_x_empty: cross cp_operations, cp_empty;

    endgroup

    function new(string name = "fifo_coverage", uvm_component parent = null);
        super.new(name, parent);
        fifo_cg = new();
    endfunction

    function void write(fifo_transaction tx);

        if (!tx.rst_n)
            return;
        
        if (tx.wr_en || tx.rd_en) begin
            if (previous_active)
                back_to_back_count++;

            previous_active = 1;
        end
        else begin
            previous_active = 0;
        end

        sample_wr_en = tx.wr_en;
        sample_rd_en = tx.rd_en;
        sample_full  = tx.full;
        sample_empty = tx.empty;

        fifo_cg.sample();
    
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("FIFO_COV", $sformatf("Functional Coverage = %0.2f%%", fifo_cg.get_inst_coverage()), UVM_LOW)

        `uvm_info("FIFO_B2B",$sformatf("Back-to-back active cycles = %0d",back_to_back_count),UVM_LOW)
    endfunction

endclass
    