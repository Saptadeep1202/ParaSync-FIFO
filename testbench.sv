`timescale 1ns/1ps
module tb_fifo_sync;

    parameter DATA_WIDTH = 8;
    parameter DEPTH = 8;

    reg clk, rst;
    reg wr_en, rd_en;
    reg [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;
    wire full, empty;
    wire [$clog2(DEPTH):0] count;

    // Instantiate FIFO
    fifo_sync #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty),
        .count(count)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // 100MHz clock (10ns period)

    // Stimulus
    initial begin
        $dumpfile("fifo_sync_tb.vcd");
        $dumpvars(0, tb_fifo_sync);

        rst = 1; wr_en = 0; rd_en = 0; din = 0;
        #15 rst = 0;

        // Write data into FIFO
        repeat (DEPTH) begin
            @(negedge clk);
            wr_en = 1; rd_en = 0;
            din = $random % 256;
        end
        @(negedge clk) wr_en = 0;

        // Try writing when full (should be ignored)
        @(negedge clk);
        wr_en = 1; din = 8'hAA;
        @(negedge clk) wr_en = 0;

        // Read all data back
        repeat (DEPTH) begin
            @(negedge clk);
            wr_en = 0; rd_en = 1;
        end
        @(negedge clk) rd_en = 0;

        // Try reading when empty (ignored)
        @(negedge clk) rd_en = 1;
        @(negedge clk) rd_en = 0;

        #50 $finish;
    end
endmodule
