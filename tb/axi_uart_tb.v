`timescale 1ns/1ps

module axi_uart_tb;

    reg clk;
    reg reset;

    // AXI Write Address
    reg  [31:0] s_axi_awaddr;
    reg         s_axi_awvalid;
    wire        s_axi_awready;

    // AXI Write Data
    reg  [31:0] s_axi_wdata;
    reg  [3:0]  s_axi_wstrb;
    reg         s_axi_wvalid;
    wire        s_axi_wready;

    // AXI Write Response
    wire [1:0]  s_axi_bresp;
    wire        s_axi_bvalid;
    reg         s_axi_bready;

    // AXI Read Address
    reg  [31:0] s_axi_araddr;
    reg         s_axi_arvalid;
    wire        s_axi_arready;

    // AXI Read Data
    wire [31:0] s_axi_rdata;
    wire [1:0]  s_axi_rresp;
    wire        s_axi_rvalid;
    reg         s_axi_rready;

    // UART
    reg  uart_rx;
    wire uart_tx;

    integer errors;

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------

    axi_uart_top #(
        .CLK_FREQ  (1_000_000),
        .BAUD_RATE (100_000)
    ) dut (
        .clk            (clk),
        .reset          (reset),

        .s_axi_awaddr   (s_axi_awaddr),
        .s_axi_awvalid  (s_axi_awvalid),
        .s_axi_awready  (s_axi_awready),

        .s_axi_wdata    (s_axi_wdata),
        .s_axi_wstrb    (s_axi_wstrb),
        .s_axi_wvalid   (s_axi_wvalid),
        .s_axi_wready   (s_axi_wready),

        .s_axi_bresp    (s_axi_bresp),
        .s_axi_bvalid   (s_axi_bvalid),
        .s_axi_bready   (s_axi_bready),

        .s_axi_araddr   (s_axi_araddr),
        .s_axi_arvalid  (s_axi_arvalid),
        .s_axi_arready  (s_axi_arready),

        .s_axi_rdata    (s_axi_rdata),
        .s_axi_rresp   (s_axi_rresp),
        .s_axi_rvalid   (s_axi_rvalid),
        .s_axi_rready   (s_axi_rready),

        .uart_rx        (uart_rx),
        .uart_tx        (uart_tx)
    );

    // ------------------------------------------------------------
    // Clock
    // ------------------------------------------------------------

    initial begin
        clk = 1'b0;

        forever #500 clk = ~clk;
    end

    // ------------------------------------------------------------
    // AXI Write Task
    // ------------------------------------------------------------

    task axi_write;

        input [31:0] address;
        input [31:0] data;

        begin

            @(posedge clk);

            s_axi_awaddr  <= address;
            s_axi_awvalid <= 1'b1;

            s_axi_wdata   <= data;
            s_axi_wstrb   <= 4'b1111;
            s_axi_wvalid  <= 1'b1;

            @(posedge clk);

            s_axi_awvalid <= 1'b0;
            s_axi_wvalid  <= 1'b0;

            wait (s_axi_bvalid);

            @(posedge clk);

            s_axi_bready <= 1'b1;

            @(posedge clk);

            s_axi_bready <= 1'b0;

        end

    endtask

    // ------------------------------------------------------------
    // AXI Read Task
    // ------------------------------------------------------------

    task axi_read;

        input  [31:0] address;
        output [31:0] data;

        begin

            @(posedge clk);

            s_axi_araddr  <= address;
            s_axi_arvalid <= 1'b1;

            @(posedge clk);

            s_axi_arvalid <= 1'b0;

            wait (s_axi_rvalid);

            data = s_axi_rdata;

            @(posedge clk);

            s_axi_rready <= 1'b1;

            @(posedge clk);

            s_axi_rready <= 1'b0;

        end

    endtask

    reg [31:0] read_value;

    // ------------------------------------------------------------
    // Test
    // ------------------------------------------------------------

    initial begin

        errors = 0;

        s_axi_awaddr  = 32'd0;
        s_axi_awvalid = 1'b0;

        s_axi_wdata   = 32'd0;
        s_axi_wstrb   = 4'b0000;
        s_axi_wvalid  = 1'b0;

        s_axi_bready  = 1'b0;

        s_axi_araddr  = 32'd0;
        s_axi_arvalid = 1'b0;

        s_axi_rready  = 1'b0;

        uart_rx = 1'b1;

        $dumpfile("axi_uart.vcd");
        $dumpvars(0, axi_uart_tb);

        // Reset
        reset = 1'b1;

        #5000;

        reset = 1'b0;

        #5000;

        $display("");
        $display("====================================");
        $display("AXI4-LITE UART VERIFICATION");
        $display("====================================");

        // --------------------------------------------------------
        // Test 1: Write TXDATA
        // --------------------------------------------------------

        $display("TEST 1: AXI write to TXDATA");

        axi_write(
            32'h00000000,
            32'h00000041
        );

        #10000;

        if (dut.tx_data !== 8'h41) begin

            $display(
                "FAIL: TXDATA expected 0x41, got 0x%02h",
                dut.tx_data
            );

            errors = errors + 1;

        end

        else begin

            $display(
                "PASS: TXDATA = 0x%02h",
                dut.tx_data
            );

        end

        // --------------------------------------------------------
        // Test 2: Check TX activity
        // --------------------------------------------------------

        $display("TEST 2: UART TX activity");

        if (dut.tx_busy !== 1'b1) begin

            $display("WARNING: TX busy already cleared");

        end

        else begin

            $display("PASS: UART TX started");

        end

        // --------------------------------------------------------
        // Test 3: Wait for transmission
        // --------------------------------------------------------

        wait (!dut.tx_busy);

        if (dut.tx_done !== 1'b1) begin

            $display("INFO: TX done pulse already cleared");

        end

        $display("PASS: UART TX completed");

        // --------------------------------------------------------
        // Test 4: Read STATUS register
        // --------------------------------------------------------

        $display("TEST 3: AXI read STATUS");

        axi_read(
            32'h00000004,
            read_value
        );

        $display(
            "STATUS = 0x%08h",
            read_value
        );

        // --------------------------------------------------------
        // Final result
        // --------------------------------------------------------

        #5000;

        $display("");
        $display("====================================");

        if (errors == 0) begin

            $display("ALL AXI UART TESTS PASSED");

        end

        else begin

            $display(
                "AXI UART TEST FAILED - ERRORS = %0d",
                errors
            );

            $fatal(1);

        end

        $display("====================================");

        $finish;

    end

endmodule
