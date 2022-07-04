`timescale 1ns/1ps

module distance_top_tb ();

reg clk;
reg rst_n;
reg							echo			;
distance_top u_distance_top(
    .clk   ( clk   ),
    .rst_n ( rst_n ),
    .echo  ( echo  ),
    .trig  ( trig  ),
    .sel   ( sel   ),
    .seg   ( seg   ),
    .led   ( led   )
);

localparam CLK_PERIOD = 2;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
    rst_n<=1'b0;
    clk<=1'b0;
    # CLK_PERIOD;
    rst_n<=1;
    echo <= 0;
    # (CLK_PERIOD * 20000);
    echo <= 1;
    # (CLK_PERIOD * 10000);
    echo <= 0;
    # (CLK_PERIOD * 20000);
    echo <= 1;
    # (CLK_PERIOD * 10000);
    echo <= 0;
    # (CLK_PERIOD *10000);
    $stop;
end

endmodule