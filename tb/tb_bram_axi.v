`timescale 1ns/1ps

module tb_bram_axi();

    // Parameters
    parameter DATA_SIZE = 32;
    parameter ADDRESS_SIZE = 12;

    // Signals
    reg clk;
    reg reset_n;

    // AXI Write Address Channel
    reg [ADDRESS_SIZE-1:0] awaddr;
    reg awvalid;
    wire awready;

    // AXI Write Data Channel
    reg [DATA_SIZE-1:0] wdata;
    reg [DATA_SIZE/8-1:0] wstrb;
    reg wvalid;
    wire wready;

    // AXI Write Response Channel
    wire [1:0] bresp;
    wire bvalid;
    reg bready;

    // AXI Read Address Channel
    reg [ADDRESS_SIZE-1:0] araddr;
    reg arvalid;
    wire arready;

    // AXI Read Data Channel
    wire [DATA_SIZE-1:0] rdata;
    wire [1:0] rresp;
    wire rvalid;
    reg rready;

    // Instantiate the DUT (Device Under Test)
    bram_axi #(
        .DATA_SIZE(DATA_SIZE)
        .ADDRESS_SIZE(ADDRESS_SIZE)
    ) dut (
        .clk(clk)
        .reset_n(reset_n)
        .awaddr(awaddr)
        .awvalid(awvalid)
        .awready(awready)
        .wdata(wdata)
        .wstrb(wstrb)
        .wvalid(wvalid)
        .wready(wready)
        .bresp(bresp)
        .bvalid(bvalid)
        .bready(bready)
        .araddr(araddr)
        .arvalid(arvalid)
        .arready(arready)
        .rdata(rdata)
        .rresp(rresp)
        .rvalid(rvalid)
        .rready(rready)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Monitor internal signals
    initial $monitor("Monitoring internal signals: (%3d) %b - %b", $time, awvalid, dut.wvalid);

    // Dump waves
    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, tb_bram_axi);
    end

    // Test process
    initial begin
        // Initialize signals
        clk = 0;
        reset_n = 0;
        awaddr = 0;
        awvalid = 0;
        wdata = 0;
        wstrb = 4'b1111; // Enable all byte lanes
        wvalid = 0;
        bready = 0;
        araddr = 0;
        arvalid = 0;
        rready = 0;

        // Apply reset
        #10 reset_n = 1;

        // Write operation
        #10 awaddr = 12'h001;
            awvalid = 1;
            wdata = 32'hDEADBEEF;
            wvalid = 1;

        // Wait for write address and data handshake
        wait(awready);
        wait(wready);
        #10 awvalid = 0;
            wvalid = 0;

        // Wait for write response
        #10 bready = 1;
        wait(bvalid);
        #10 bready = 0;

        // Read operation
        #10 araddr = 12'h001;
            arvalid = 1;
            rready = 1;

        // Wait for read address handshake
        wait(arready);
        #10 arvalid = 0;

        // Wait for read data
        wait(rvalid);
        #10 rready = 0;

        // Check read data
        if (rdata == 32'hDEADBEEF) begin
            $display("Test Passed: Read data matches written data.");
        end else begin
            $display("Test Failed: Read data does not match written data.");
        end

        // End of simulation
        #20 $finish;
    end

endmodule
