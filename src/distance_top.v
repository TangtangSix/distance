module distance_top (
    input			wire						clk,
    input			wire						rst_n,
    input			wire						echo,
    
    output			wire						trig,
    output			wire		[ 5:0 ]			sel,
    output			wire		[ 7:0 ]			seg,
    output			reg		    [ 3:0 ]			led,
    output			wire						beep,
    input			wire						key,
    output			wire						h_sync,
    output			wire						v_sync,
    output			wire		[ 4:0 ]			rgb_r,
    output			wire		[ 5:0 ]			rgb_g,
    output			wire		[ 4:0 ]			rgb_b,
    input			wire						rx_data,
    output			wire						tx_data
);

wire							clk_50			;
wire							clk_1			;
wire							clk_25			;
wire		[ 23:0 ]			distance_data			;
wire							data_out_vld			;
reg							    beep_vld			;
wire							key_out			;
wire		[ 15:0 ]			rgb_data			;
wire		[ 11:0 ]		    addr_h;
wire		[ 11:0 ]		    addr_v;
pll	pll_inst (
	.areset ( ~rst_n ),
	.inclk0 ( clk ),
	.c0 ( clk_50 ),
	.c1 ( clk_1 ),
	.c2 ( clk_25 )
	);

//vga
vga_dirve u_vga_dirve(
    .clk      ( clk_25   ),
    .rst_n    ( rst_n    ),
    .rgb_data ( rgb_data ),
    .vga_clk  ( vga_clk  ),
    .h_sync   ( h_sync   ),
    .v_sync   ( v_sync   ),
    .addr_h   ( addr_h   ),
    .addr_v   ( addr_v   ),
    .rgb_r    ( rgb_r    ),
    .rgb_g    ( rgb_g    ),
    .rgb_b    ( rgb_b    )
);
//vag数据
data_drive u_data_drive(
    .clk           (clk),
    .vga_clk       ( vga_clk       ),
    .rst_n         ( rst_n         ),
    .addr_h        ( addr_h        ),
    .addr_v        ( addr_v        ),
    .data_vld      ( data_out_vld   ),
    .distance_data ( distance_data ),
    .rgb_data      ( rgb_data      )
);
//数码管
seg_drive u_seg_drive(
    .clk          ( clk          ),
    .rst_n        ( rst_n        ),
    .data_vld     ( data_out_vld ),
    .display_data ( distance_data),
    .sel          ( sel          ),
    .seg          ( seg          )
);
sel_drive u_sel_drive(
    .clk   ( clk_50   ),
    .rst_n ( rst_n ),
    .sel   ( sel   )
);
//测距
distance_drive u_distance(
    .clk           ( clk           ),
    .clk_1          (clk_1),
    .rst_n         ( rst_n         ),
    .echo          ( echo          ),
    .trig          ( trig          ),
    .data_out_vld  ( data_out_vld ),
    .distance_data ( distance_data )
);
//串口
uart_drive u_uart_drive(
    .clk           ( clk           ),
    .rst_n         ( rst_n         ),
    .distance_data ( distance_data ),
    .data_vld      ( data_out_vld   ),
    .rx_data       ( rx_data       ),
    .tx_data       ( tx_data       )
);

//蜂鸣器
beep_dirve u_beep_dirve(
    .clk           ( clk           ),
    .rst_n         ( rst_n         ),
    .beep_vld      ( beep_vld      ),
    .data_vld      ( data_out_vld      ),
    .distance_data ( distance_data ),
    .beep          ( beep          )
);
//按键消抖
key_debounce#(.KEY_W   ( 1 )) u_key_debounce(
    .clk     ( clk     ),
    .rst_n   ( rst_n   ),
    .key_in  ( key  ),
    .key_out  ( key_out  )
);

//控制蜂鸣器使能
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        beep_vld <= 0;
    end
    else if(key_out) begin
        beep_vld <= ~beep_vld;
    end
end
reg			[ 27:0 ]			cnt			        ;
// led
always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        cnt <= 0;
    end
    else if ( cnt == 50_000_000 - 1 ) begin
        cnt <= 0;
    end
    else begin
        cnt <= cnt + 1;
    end
end

always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        led <= 4'b0000;
    end
    else if ( cnt == 50_000_000 -1 )begin
        led <= ~led;
    end
    else begin
        led <= led;
    end
end
endmodule //distance_top