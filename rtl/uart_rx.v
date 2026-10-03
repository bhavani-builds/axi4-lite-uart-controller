module uart_rx (
    input  wire       clk,
    input  wire       reset,
    input  wire       baud_tick,

    input  wire       rx,

    output reg [7:0]  rx_data,
    output reg       rx_valid,
    output reg       rx_busy
);

    reg [3:0] bit_count;
    reg [7:0] data_reg;

    always @(posedge clk) begin

        if (reset) begin
            rx_data   <= 8'd0;
            rx_valid  <= 1'b0;
            rx_busy   <= 1'b0;
            bit_count <= 4'd0;
            data_reg  <= 8'd0;
        end

        else begin

            rx_valid <= 1'b0;

            // Detect start bit
            if (!rx && !rx_busy) begin
                rx_busy   <= 1'b1;
                bit_count <= 4'd0;
            end

            else if (rx_busy && baud_tick) begin

                case (bit_count)

                    4'd0: begin
                        // Start bit
                        if (!rx) begin
                            bit_count <= 4'd1;
                        end
                        else begin
                            // Invalid start bit
                            rx_busy <= 1'b0;
                        end
                    end

                    4'd1: begin
                        data_reg[0] <= rx;
                        bit_count <= 4'd2;
                    end

                    4'd2: begin
                        data_reg[1] <= rx;
                        bit_count <= 4'd3;
                    end

                    4'd3: begin
                        data_reg[2] <= rx;
                        bit_count <= 4'd4;
                    end

                    4'd4: begin
                        data_reg[3] <= rx;
                        bit_count <= 4'd5;
                    end

                    4'd5: begin
                        data_reg[4] <= rx;
                        bit_count <= 4'd6;
                    end

                    4'd6: begin
                        data_reg[5] <= rx;
                        bit_count <= 4'd7;
                    end

                    4'd7: begin
                        data_reg[6] <= rx;
                        bit_count <= 4'd8;
                    end

                    4'd8: begin
                        data_reg[7] <= rx;
                        bit_count <= 4'd9;
                    end

                    4'd9: begin
                        // Stop bit
                        if (rx) begin
                            rx_data  <= data_reg;
                            rx_valid <= 1'b1;
                        end

                        rx_busy   <= 1'b0;
                        bit_count <= 4'd0;
                    end

                    default: begin
                        rx_busy <= 1'b0;
                    end

                endcase

            end

        end

    end

endmodule
