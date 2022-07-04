module uart_rx (input			wire						clk,    
                input			wire						rst_n,

                input			wire						data, //接受数据
                input			wire		[ 19:0 ]		rx_bps,//波特率
                output			wire		[ 07:0 ]		data_out,//串转并数据
                output			wire						rx_done //接受完毕标志
                );


localparam MAX_BIT = 10;

reg								data_r1			            ;       //打拍,边缘检测
reg								data_r2			            ;
reg			[ 12:0 ]			cnt_bps			            ;                   //波特率计数器
reg			[ 03:0 ]			cnt_bit			            ;                   //数据位计数器
reg			[ 07:0 ]			data_out_r			        ;
reg							    flag_enable_cnt_bit			;       //数据位计数器使能

wire		[ 12:0 ]			max_bps			            ;                   
wire							flag_clear_cnt_bps			;       //波特率计数器清零
wire							flag_add_cnt_bit			;       //数据位+1
wire							flag_clear_cnt_bit			;       //数据位计数器清零
wire							flag_begin_cnt_bit			;       //数据位计数器开始计数
wire							flag_begin_sample			;       //开始采样
wire							flag_enable_cnt_bps			;       

//波特率计数器
always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        cnt_bps <= 0;
    end
    else if ( flag_enable_cnt_bps ) begin
        if ( flag_clear_cnt_bps ) begin
            cnt_bps <= 0;
        end
        else begin
            cnt_bps <= cnt_bps + 1;
        end
    end
    else begin
        cnt_bps <= 0;
    end
end
assign flag_enable_cnt_bps = flag_enable_cnt_bit;
assign flag_clear_cnt_bps = cnt_bps >= max_bps -1;
assign max_bps            = 50_000_000 / rx_bps;

// 下降沿到来开启数据位计数器,接收完毕关闭
always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        flag_enable_cnt_bit <= 0;
    end
    else if ( flag_begin_cnt_bit ) begin
        flag_enable_cnt_bit <= 1;
    end
    else if ( flag_clear_cnt_bit ) begin
        flag_enable_cnt_bit <= 0;
        end
    else begin
        flag_enable_cnt_bit <= flag_enable_cnt_bit;
    end
    
end

//bit计数器
always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        cnt_bit <= 0;
    end
    else if ( flag_enable_cnt_bit ) begin
        if ( flag_clear_cnt_bit ) begin
            cnt_bit <= 0;
        end
        else if ( flag_add_cnt_bit ) begin
            cnt_bit <= cnt_bit + 1;
        end
        else begin
            cnt_bit <= cnt_bit;
        end
    end
    else begin
        cnt_bit <= 0;
    end
end

assign flag_clear_cnt_bit  = cnt_bit >= MAX_BIT - 1 && flag_clear_cnt_bps;
assign flag_add_cnt_bit =  flag_clear_cnt_bps;

//下降沿检测
always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        data_r1 <= 1;
        data_r2 <= 1;
    end
    else begin
        data_r1 <= data_r2;
        data_r2 <= data;
    end
end
assign flag_begin_cnt_bit = data_r1 && ~data_r2 && ~flag_enable_cnt_bit;

//采样
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_out_r <= 8'b0;
    end
    else if(flag_begin_sample) begin
        data_out_r [cnt_bit - 1] = data;//移位赋值
    end
    else if(flag_clear_cnt_bit) begin
        data_out_r<= 0;
    end
end

//在1~8bit的中间时刻采样
assign flag_begin_sample = flag_enable_cnt_bit && cnt_bps == max_bps >>1 && cnt_bit >0  && cnt_bit < 9;
assign rx_done = flag_clear_cnt_bit;
assign data_out = data_out_r;

endmodule // uart_rx
