module fifo_assertions #(
    parameter int DEPTH = 16
)(
    input logic clk,
    input logic rst_n,
    input logic wr_en,
    input logic rd_en,
    input logic full,
    input logic empty
);

    // Assertion 1: FIFO cannot be full and empty simultaneously.
    ap_not_full_and_empty:
        assert property (@(posedge clk)
            disable iff (!rst_n)
            !(full && empty)
        )
        else $error("FIFO cannot be full and empty simultaneously");


    // Assertion 2: A write-only request while full must leave the FIFO full on the next cycle.
    ap_overflow_protection:
        assert property (@(posedge clk)
            disable iff (!rst_n)
            (full && wr_en && !rd_en) |=> full
        )
        else $error("FIFO overflow protection failed");


    // Assertion 3: A read-only request while empty must leave the FIFO empty on the next cycle.
    ap_underflow_protection:
        assert property (@(posedge clk)
            disable iff (!rst_n)
            (empty && rd_en && !wr_en) |=> empty
        )
        else $error("FIFO underflow protection failed");
    

    // Assertion 4: An accepted write-only operation must make the FIFO non-empty on the next cycle.
    ap_write_makes_nonempty:
        assert property (@(posedge clk)
            disable iff (!rst_n)
            (wr_en && !full && !rd_en) |=> !empty
        )
        else $error("FIFO remained empty after accepted write");


    // Assertion 5: An accepted read-only operation must make the FIFO non-full on the next cycle.
    ap_read_makes_nonfull:
        assert property (@(posedge clk)
            disable iff (!rst_n)
            (rd_en && !empty && !wr_en) |=> !full
        )
        else $error("FIFO remained full after accepted read");


endmodule
