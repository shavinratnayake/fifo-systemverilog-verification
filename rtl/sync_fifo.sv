`timescale 1ns/1ps

module sync_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH = 16
)(
    input logic clk,
    input logic rst_n,

    input logic wr_en,
    input logic [DATA_WIDTH-1:0] wr_data,

    input logic rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,

    output logic full,
    output logic empty
);

    localparam int PTR_WIDTH = $clog2(DEPTH);

    logic [DATA_WIDTH-1:0] MEM [0:DEPTH-1];

    logic [PTR_WIDTH-1:0] wr_ptr;
    logic [PTR_WIDTH-1:0] rd_ptr;

    logic [PTR_WIDTH:0] count;

    assign empty = (count == 0);
    assign full = (count == (PTR_WIDTH + 1)'(DEPTH));



    always_ff @(posedge clk) begin

        if (!rst_n) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            count <= '0;
            rd_data <= '0;
        end

        else begin

            // Writing block
            if (wr_en && !full) begin
                MEM[wr_ptr] <= wr_data;

                if (wr_ptr == PTR_WIDTH'(DEPTH - 1))
                    wr_ptr <= '0;
                else
                    wr_ptr <= wr_ptr + 1'b1;
            end

            // Reading block
            if (rd_en && !empty) begin
                rd_data <= MEM[rd_ptr];

                if (rd_ptr == PTR_WIDTH'(DEPTH - 1))
                    rd_ptr <= '0;
                else
                    rd_ptr <= rd_ptr + 1'b1;
            end

            case ({wr_en && !full, rd_en && !empty})

                2'b10: count <= count + 1'b1;

                2'b01: count <= count - 1'b1;

                default: count <= count;

            endcase
        end
    end
        
endmodule
