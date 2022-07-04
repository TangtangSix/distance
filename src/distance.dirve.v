module distance_drive (
    input			wire						clk,
    input			wire						clk_1,
    input			wire						rst_n,

    input			wire						echo,
    output			reg						    trig,
    output			wire						data_out_vld,
    output			wire		[ 23:0 ]		distance_data
);
localparam	MAX_DISTANCE = 117647; //最大距离 4m

parameter	s_idle = 0;//空闲状态
parameter	s_send = 1;//发送触发信号
parameter	s_wait = 2;//等待内部发送脉冲
parameter	s_accept = 3;//检测回响信号
parameter	s_accept_wait = 4;//延时等待


reg								echo_r0			;
reg								echo_r1			;
reg			[ 2:0 ]			    s_current		;
reg			[ 2:0 ]			    s_next			;
reg			[ 22 :0 ]		    cnt				;
reg			[ 22:0 ]			cnt_wait		;
reg			[ 22:0 ]		    cnt_max			;
reg			[ 16:0 ]			cnt_distance	;
// reg			[ 25:0 ]			cnt_distance_r1			;
// reg			[ 19:0 ]			cnt_distance_r2			;

wire							accept_start_sig			;
wire							accept_stop_sig			;
wire							idle_sig			;
wire							send_sig			;
// wire							wait_sig			;
wire							flag_clear_cnt			;
wire							flag_clear_cnt_wait			;
reg			[ 19:0 ]			distance_data_r			;
wire			[ 23:0 ]			distance_data_r1			;

assign idle_sig = s_current == s_idle;
assign send_sig = s_current == s_send && flag_clear_cnt;
// assign wait_sig = s_current == s_wait && flag_clear_cnt_wait;
assign accept_wait_sig = s_current == s_accept_wait &&  flag_clear_cnt_wait;
assign accept_start_sig = s_current == s_wait && echo_r0 && ~echo_r1;
assign accept_stop_sig = s_current == s_accept && (~echo_r0 && echo_r1);


// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         cnt_distance_r1 <= 0;
//         // cnt_distance_r2 <= 0;
//     end
//     else begin
//         cnt_distance_r1 <= cnt_distance * 340 / 100;
//         // cnt_distance_r2 <= cnt_distance_r1 >> 4;
//     end
// end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        echo_r0 <= 0;
        echo_r1 <= 0;
    end
    else begin
        echo_r0 <= echo;
        echo_r1 <= echo_r0;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        s_current <= s_idle;    
    end
    else begin
        s_current <= s_next;
    end
end

always @(*) begin
    case (s_current)
        s_idle : begin
            if(idle_sig) begin
                s_next = s_send;
            end
            else begin
                s_next = s_idle;
            end
        end
        s_send : begin
            if(send_sig) begin
                s_next = s_wait;
            end
            else begin
                s_next = s_send;
            end
        end
        s_wait : begin
            if(accept_start_sig) begin
                s_next = s_accept;
            end
            else begin
                s_next = s_wait;
            end
        end
        s_accept : begin
            if(accept_stop_sig) begin
                s_next = s_accept_wait;
            end
            else begin
                s_next = s_accept;
            end
        end
        s_accept_wait : begin
            if(accept_wait_sig) begin
                s_next <= s_idle;
            end
            else begin
                s_next <= s_accept_wait;
            end
        end
        default: s_next = s_idle;
    endcase
end

//距离
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        distance_data_r <= 0;
    end
    else if(accept_stop_sig) begin
        distance_data_r <= cnt_distance * 340 / 200;
    end
end

//转BCD码
assign     distance_data_r1[3:0]   = distance_data_r % 10;
assign     distance_data_r1[7:4]   = distance_data_r / 10 % 10;
assign     distance_data_r1[11:8]  = distance_data_r / 100 % 10;
assign     distance_data_r1[15:12] = distance_data_r / 1000 % 10;
assign     distance_data_r1[19:16] = distance_data_r / 10000 % 10;
assign     distance_data_r1[23:20] = distance_data_r / 100000 % 10;

assign data_out_vld = accept_wait_sig;
assign distance_data = distance_data_r1;

//回响信号计数器
always @(posedge clk_1 or negedge rst_n) begin
    if(!rst_n) begin
        cnt_distance <= 0;
    end
    else if(accept_start_sig) begin
        cnt_distance <= 0;
    end
    else if(s_current == s_accept) begin
        cnt_distance <= cnt_distance + 1;
    end
    else begin
        cnt_distance <= 0;
    end
end

//发送触发信号
always @(posedge clk_1 or negedge rst_n) begin
    case (s_current)
        s_idle : begin
            trig <= 0;
        end
        s_send : begin
            trig <= 1;
        end
        s_wait : begin
            trig <= 0;
        end
        s_accept : begin
            trig <= 0;
        end
        s_accept_wait : begin
            trig <= 0;
        end
        default: begin
            trig <= 0;
        end
    endcase
end
//等待发送玩脉冲
always @( posedge clk_1 or negedge rst_n ) begin
    if ( !rst_n ) begin
        cnt <= 0;
    end
    else if ( s_current == s_send ) begin
        if ( flag_clear_cnt == 9 ) begin
            cnt <= 0;
        end
        else begin
            cnt <= cnt + 1;
        end
    end
    else begin
        cnt <= 0;
    end
end
assign flag_clear_cnt = cnt == 9;

//延时计数器
always @( posedge clk_1 or negedge rst_n ) begin
    if ( !rst_n ) begin
        cnt_wait <= 0;
    end
    else if ( s_current == s_accept_wait ) begin
        if ( flag_clear_cnt_wait ) begin
            cnt_wait <= 0;
        end
        else begin
            cnt_wait <= cnt_wait + 1;
        end
    end
    else begin
        cnt_wait <= 0;
    end
end
assign flag_clear_cnt_wait = cnt_wait == 250_000;
endmodule //distance