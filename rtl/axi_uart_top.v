module axi_uart_top #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 115_200
)(
    input wire        clk,
    input wire        reset,

    // AXI4-Lite Write Address
    input wire [31:0] s_axi_awaddr,
    input wire        s_axi_awvalid,
    output wire       s_axi_awready,

    // AXI4-Lite Write Data
    input wire [31:0] s_axi_wdata,
    input wire [3:0]  s_axi_wstrb,
    input wire        s_axi_wvalid,
    output wire       s_axi_wready,

    // AXI4-Lite Write Response
    output wire [1:0] s_axi_bresp,
    output wire       s_axi_bvalid,
    input wire        s_axi_bready,

    // AXI4-Lite Read Address
    input wire [31:0] s_axi_araddr,
    input wire        s_axi_arvalid,
    output wire       s_axi_arready,

    // AXI4-Lite Read Data
    output wire [31:0] s_axi_rdata,
    output wire [1:0]  s_axi_rresp,
    output wire        s_axi_rvalid,
    input wire         s_axi_rready,

    // UART
    input wire         uart_rx,
    output wire        uart_tx
);

    // ============================================================
    // Baud Generator
    // ============================================================

    wire baud_tick;

    baud_generator #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) baud_gen (
        .clk       (clk),
        .reset     (reset),
        .baud_tick (baud_tick)
    );

    // ============================================================
    // AXI Register Interface
    // ============================================================

    wire        reg_write;
    wire [31:0] reg_write_addr;
    wire [31:0] reg_write_data;

    wire        reg_read;
    wire [31:0] reg_read_addr;
    wire [31:0] reg_read_data;

    axi_lite_slave axi_slave (
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
        .s_axi_rresp    (s_axi_rresp),
        .s_axi_rvalid   (s_axi_rvalid),
        .s_axi_rready   (s_axi_rready),

        .reg_write      (reg_write),
        .reg_write_addr (reg_write_addr),
        .reg_write_data (reg_write_data),

        .reg_read       (reg_read),
        .reg_read_addr  (reg_read_addr),

        .reg_read_data  (reg_read_data)
    );

    // ============================================================
    // UART Signals
    // ============================================================

    wire [7:0] tx_data;
    wire       tx_start;
    wire       tx_busy;
    wire       tx_done;

    wire [7:0] rx_data;
    wire       rx_valid;
    wire       rx_busy;

    // ============================================================
    // UART Registers
    // ============================================================

    uart_registers uart_regs (
        .clk            (clk),
        .reset          (reset),

        .reg_write      (reg_write),
        .reg_write_addr (reg_write_addr),
        .reg_write_data (reg_write_data),

        .reg_read       (reg_read),
        .reg_read_addr  (reg_read_addr),
        .reg_read_data  (reg_read_data),

        .tx_data        (tx_data),
        .tx_start       (tx_start),
        .tx_busy        (tx_busy),
        .tx_done        (tx_done),

        .rx_data        (rx_data),
        .rx_valid       (rx_valid),
        .rx_busy        (rx_busy)
    );

    // ============================================================
    // UART Transmitter
    // ============================================================

    uart_tx transmitter (
        .clk       (clk),
        .reset     (reset),
        .baud_tick (baud_tick),

        .tx_data   (tx_data),
        .tx_start  (tx_start),

        .tx        (uart_tx),
        .tx_busy   (tx_busy),
        .tx_done   (tx_done)
    );

    // ============================================================
    // UART Receiver
    // ============================================================

    uart_rx receiver (
        .clk       (clk),
        .reset     (reset),
        .baud_tick (baud_tick),

        .rx        (uart_rx),

        .rx_data   (rx_data),
        .rx_valid  (rx_valid),
        .rx_busy   (rx_busy)
    );

endmodule
