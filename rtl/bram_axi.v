module bram_axi #(
    parameter DATA_SIZE = 32, // Default to 32-bit data size
    parameter ADDRESS_SIZE = 12 // 2^12 addresses
) (
    // AXI Signals
    input wire clk,
    input wire reset_n,

    // AXI Write Address Channel
    input wire [ADDRESS_SIZE-1:0] awaddr,
    input wire awvalid,
    output wire awready,

    // AXI Write Data Channel
    input wire [DATA_SIZE-1:0] wdata,
    input wire [DATA_SIZE/8-1:0] wstrb,
    input wire wvalid,
    output wire wready,

    // AXI Write Response Channel
    output wire [1:0] bresp,
    output wire bvalid,
    input wire bready,

    // AXI Read Address Channel
    input wire [ADDRESS_SIZE-1:0] araddr,
    input wire arvalid,
    output wire arready,

    // AXI Read Data Channel
    output wire [DATA_SIZE-1:0] rdata,
    output wire [1:0] rresp,
    output wire rvalid,
    input wire rready
);

    // Internal signals
    reg [DATA_SIZE-1:0] mem [2**ADDRESS_SIZE-1:0]; // Memory array
    reg awready_reg, wready_reg, arready_reg;
    reg [DATA_SIZE-1:0] rdata_reg;
    reg bvalid_reg, rvalid_reg;

    // Write Address Channel Logic
    assign awready = awready_reg;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            awready_reg <= 1'b0;
        end else if (awvalid && !awready_reg) begin
            awready_reg <= 1'b1;
        end else begin
            awready_reg <= 1'b0;
        end
    end

    // Write Data Channel Logic
    assign wready = wready_reg;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            wready_reg <= 1'b0;
        end else if (wvalid && awvalid && awready_reg && !wready_reg) begin
            wready_reg <= 1'b1;
            // Write to memory
            if (wstrb[0]) mem[awaddr][7:0]   <= wdata[7:0];
            if (wstrb[1]) mem[awaddr][15:8]  <= wdata[15:8];
            if (wstrb[2]) mem[awaddr][23:16] <= wdata[23:16];
            if (wstrb[3]) mem[awaddr][31:24] <= wdata[31:24];
        end else begin
            wready_reg <= 1'b0;
        end
    end

    // Write Response Channel Logic
    assign bresp = 2'b00; // OKAY response
    assign bvalid = bvalid_reg;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            bvalid_reg <= 1'b0;
        end else if (wready_reg && wvalid && !bvalid_reg) begin
            bvalid_reg <= 1'b1;
        end else if (bready && bvalid_reg) begin
            bvalid_reg <= 1'b0;
        end
    end

    // Read Address Channel Logic
    assign arready = arready_reg;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            arready_reg <= 1'b0;
        end else if (arvalid && !arready_reg) begin
            arready_reg <= 1'b1;
        end else begin
            arready_reg <= 1'b0;
        end
    end

    // Read Data Channel Logic
    assign rdata = rdata_reg;
    assign rresp = 2'b00; // OKAY response
    assign rvalid = rvalid_reg;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rvalid_reg <= 1'b0;
            rdata_reg <= {DATA_SIZE{1'b0}};
        end else if (arready_reg && arvalid && !rvalid_reg) begin
            rvalid_reg <= 1'b1;
            rdata_reg <= mem[araddr];
        end else if (rready && rvalid_reg) begin
            rvalid_reg <= 1'b0;
        end
    end
endmodule
