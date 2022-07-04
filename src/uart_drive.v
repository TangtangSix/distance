module uart_drive (
    input			wire						clk,
    input			wire						rst_n,
    input			wire		[ 23:0 ]		distance_data,
    input			wire						data_vld,
    output			wire						rx_data,
    output			wire						tx_data
);
reg			[ 23:0 ]			distance_data_r			;
reg			[ 7:0 ]				data		;
reg			[ 3:0 ]				cnt_byte		;
reg								send_flag			;
wire		[ 7:0 ]			    distance			;
wire							rdreq			;
wire							wrreq			;
wire							empty			;
wire							full			;
wire		[ 7:0 ]			    data_in			;

reg								flag			;
//串口
uart_tx u_uart_tx(
    .clk       ( clk       ),
    .rst_n     ( rst_n     ),
    .tx_enable ( rdreq      ),
    .data_in   ( data_in   ),
    .tx_bps    ( 115200    ),
    .data      ( tx_data      ),
    .tx_done   ( tx_done   )
);

assign rdreq = tx_done && ~empty;
assign wrreq = ~full && send_flag && (cnt_byte > 0) && flag;
assign distance = data;
tx_fifo	tx_fifo_inst (
	.aclr ( ~rst_n ),
	.clock ( clk ),
	.data ( distance ),
	.rdreq ( rdreq ),
	.wrreq ( wrreq ),
	.empty ( empty ),
	.full ( full ),
	.q ( data_in ),
	.usedw ( usedw_sig )
	);


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        send_flag <= 0;
    end
    else if(cnt_byte == 9) begin
        send_flag <= 0;
    end
    else if(data_vld) begin
        send_flag <= 1;
    end

end
//数据计数器
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt_byte <=0;
    end
    else if(cnt_byte == 9) begin
        cnt_byte <= 0;
    end
    else if(send_flag) begin
        cnt_byte <= cnt_byte + 1;
    end
end
//寄存数据
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        distance_data_r <=0;
    end
    else if(data_vld) begin
        distance_data_r <= distance_data;
    end
end

//去除前面的不必要的0
always @(*) begin
    if(!rst_n) begin
        flag = 0;
    end
    else if(!send_flag) begin
        flag <= 0;
    end
    else if(cnt_byte > 3 || data> 48) begin
        flag = 1;
    end
    else begin
        flag <= flag;
    end
end
//发送距离
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data <=0;
    end
    else if(send_flag) begin
        case (cnt_byte)
            0 : data <= distance_data_r[23:20] + 48;
            1 : data <= distance_data_r[19:19] + 48;
            2 : data <= distance_data_r[15:12] + 48;
            3 : data <= distance_data_r[11:8 ] + 48;
            4 : data <= 46; // .
            5 : data <= distance_data_r[7 : 4] + 48;
            6 : data <= distance_data_r[3 : 0] + 48;
            7 : data <= 99 ; //c
            8 : data <= 109; //m
            default: data <=0;
        endcase
        // data <= distance_data_r[(4 * (6-cnt_byte) -1) -:4] + 48;
    end
end

endmodule //uart_drive