// Parameterized Synchronous FIFO
module fifo_sync #(
    parameter DATA_WIDTH = 8,   // Data bus width
    parameter DEPTH = 16        // FIFO depth
)(
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  wr_en,   // Write enable
    input  wire                  rd_en,   // Read enable
    input  wire [DATA_WIDTH-1:0] din,     // Data input
    output reg  [DATA_WIDTH-1:0] dout,    // Data output
    output wire                  full,    // FIFO full flag
    output wire                  empty,   // FIFO empty flag
    output reg  [$clog2(DEPTH):0] count   // FIFO element count
);

    // Memory array
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Read and write pointers
    reg [$clog2(DEPTH)-1:0] w_ptr, r_ptr;

    // Assign flags
    assign full  = (count == DEPTH);
    assign empty = (count == 0);

    // Sequential logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            w_ptr <= 0;
            r_ptr <= 0;
            count <= 0;
            dout  <= 0;
        end else begin
            // Write operation
            if (wr_en && !full) begin
                mem[w_ptr] <= din;
                w_ptr <= w_ptr + 1;
                count <= count + 1;
            end
            // Read operation
            if (rd_en && !empty) begin
                dout <= mem[r_ptr];
                r_ptr <= r_ptr + 1;
                count <= count - 1;
            end
        end
    end
endmodule
