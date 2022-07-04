module uart_tx(input			wire						clk,
               input			wire						rst_n,
               input			wire						tx_enable, // 发送使能
               input			wire		[ 07:0 ]		data_in, // 需要发送的数据
               input			wire		[ 19:0 ]		tx_bps, // 发送的波特率
               output			wire						data, // 发送的数据
               output			wire						tx_done);
    
    localparam MAX_BIT = 10;
    
    reg			[ 09:0 ]			data_r			; // 数据寄存器
    reg			[ 12:0 ]			cnt_bps			; // 波特率计数器
    reg			[ 03:0 ]			cnt_bit			; // 数据位计数器
    
    wire		[ 12:0 ]			max_bps			; // 波特率对应频率

    wire							flag_clear_cnt_bps			; // 计数器归零
    wire							flag_add_cnt_bit			; // 计数器+1
    wire							flag_clear_cnt_bit			; 
    reg								flag_send_data			    ; //发送数据标志
    
    //输入数据寄存
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data_r <= 10'b0;
        end
        else if(tx_enable) begin
            data_r <={1'b1, data_in, 1'b0};
        end

    end
    
    // 波特率计数器
    always @( posedge clk or negedge rst_n ) begin
        if ( !rst_n ) begin
            cnt_bps <= 0;
        end
        else if ( flag_send_data ) begin
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

    assign flag_clear_cnt_bps  = cnt_bps >= max_bps -1;
    assign max_bps             = 50_000_000 / tx_bps;
    
    // 数据位计数器
    always @( posedge clk or negedge rst_n ) begin
        if ( !rst_n ) begin
            cnt_bit <= 0;
        end
        else if ( flag_send_data ) begin
            if ( flag_clear_cnt_bit ) begin
                cnt_bit <= 0;
            end
            else if ( flag_add_cnt_bit )begin
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

    assign flag_add_cnt_bit   = flag_clear_cnt_bps;
    assign flag_clear_cnt_bit = cnt_bit >= MAX_BIT - 1 && flag_add_cnt_bit ;


    //发送数据标志
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            flag_send_data <= 0;
        end
        else if(tx_enable) begin
            flag_send_data <= 1;
        end
        else if(flag_clear_cnt_bit) begin
            flag_send_data <= 0;
        end
        else begin
            flag_send_data <= flag_send_data;
        end
    end
    //发送数据
    assign data = flag_send_data ? data_r[cnt_bit]:1;
    assign tx_done = ~flag_send_data  ;
    //发送状态
    // always @(*) begin
    //     if(!rst_n) begin
    //         tx_done = 1;
    //     end
    //     else if(flag_clear_cnt_bit) begin
    //         tx_done = 1;
    //     end
    //     else if(flag_send_data) begin
    //         tx_done = 0;
    //     end
    //     else begin
    //         tx_done = tx_done;
    //     end
    // end

 
endmodule
