module uart_registers (
    input wire        clk,
    input wire        reset,

    // AXI register interface
    input wire        reg_write,
    input wire [31:0] reg_write_addr,
    input wire [31:0] reg_write_data,

    input wire        reg_read,
    input wire [31:0] reg_read_addr,

    output reg [31:0] reg_read_data,

    // UART TX interface
    output reg [7:0]  tx_data,
    output reg        tx_start,
    input wire        tx_busy,
    input wire        tx_done,

    // UART RX interface
    input wire [7:0]  rx_data,
    input wire        rx_valid,
    input wire        rx_busy
);

    // Register addresses
    localparam ADDR_TXDATA = 32'h00000000;
    localparam ADDR_STATUS = 32'h00000004;
    localparam ADDR_RXDATA = 32'h00000008;

    always @(posedge clk) begin

        if (reset) begin
            tx_data  <= 8'd0;
            tx_start <= 1'b0;
        end

        else begin

            // TX start is a one-cycle pulse
            tx_start <= 1'b0;

            // Write TXDATA register
            if (reg_write &&
                (reg_write_addr == ADDR_TXDATA)) begin

                tx_data  <= reg_write_data[7:0];
                tx_start <= 1'b1;

            end

        end

    end

    // Register read multiplexer
    always @(*) begin

        reg_read_data = 32'd0;

        if (reg_read) begin

            case (reg_read_addr)

                ADDR_TXDATA: begin
                    reg_read_data = {24'd0, tx_data};
                end

                ADDR_STATUS: begin
                    reg_read_data = {
                        29'd0,
                        rx_busy,
                        tx_done,
                        tx_busy
                    };
                end

                ADDR_RXDATA: begin
                    reg_read_data = {24'd0, rx_data};
                end

                default: begin
                    reg_read_data = 32'd0;
                end

            endcase

        end

    end

endmodule
