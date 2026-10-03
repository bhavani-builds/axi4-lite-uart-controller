module baud_generator #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  wire clk,
    input  wire reset,

    output reg baud_tick
);

    localparam integer BAUD_DIV = CLK_FREQ / BAUD_RATE;

    reg [31:0] counter;

    always @(posedge clk) begin

        if (reset) begin
            counter  <= 32'd0;
            baud_tick <= 1'b0;
        end

        else begin

            if (counter == BAUD_DIV - 1) begin
                counter   <= 32'd0;
                baud_tick <= 1'b1;
            end

            else begin
                counter   <= counter + 1'b1;
                baud_tick <= 1'b0;
            end

        end

    end

endmodule
