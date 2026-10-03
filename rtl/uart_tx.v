module uart_tx (
    input  wire       clk,
    input  wire       reset,
    input  wire       baud_tick,

    input  wire [7:0] tx_data,
    input  wire       tx_start,

    output reg        tx,
    output reg        tx_busy,
    output reg        tx_done
);

    reg [3:0] bit_count;
    reg [7:0] data_reg;

    always @(posedge clk) begin

        if (reset) begin
            tx        <= 1'b1;
            tx_busy   <= 1'b0;
            tx_done   <= 1'b0;
            bit_count <= 4'd0;
            data_reg  <= 8'd0;
        end

        else begin

            tx_done <= 1'b0;

            if (tx_start && !tx_busy) begin

                data_reg  <= tx_data;
                tx_busy   <= 1'b1;
                bit_count <= 4'd0;

                // Start bit
                tx <= 1'b0;

            end

            else if (tx_busy && baud_tick) begin

                case (bit_count)

                    4'd0: begin
                        tx <= data_reg[0];
                    end

                    4'd1: begin
                        tx <= data_reg[1];
                    end

                    4'd2: begin
                        tx <= data_reg[2];
                    end

                    4'd3: begin
                        tx <= data_reg[3];
                    end

                    4'd4: begin
                        tx <= data_reg[4];
                    end

                    4'd5: begin
                        tx <= data_reg[5];
                    end

                    4'd6: begin
                        tx <= data_reg[6];
                    end

                    4'd7: begin
                        tx <= data_reg[7];
                    end

                    4'd8: begin
                        // Stop bit
                        tx <= 1'b1;
                    end

                    4'd9: begin
                        tx_busy   <= 1'b0;
                        tx_done   <= 1'b1;
                        tx        <= 1'b1;
                        bit_count <= 4'd0;
                    end

                    default: begin
                        tx_busy <= 1'b0;
                        tx      <= 1'b1;
                    end

                endcase

                bit_count <= bit_count + 1'b1;

            end

        end

    end

endmodule
