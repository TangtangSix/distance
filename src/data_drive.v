module data_drive (input			wire						clk,
                    input			wire						vga_clk,
                   input			wire						rst_n,
                   input			wire		[ 11:0 ]		addr_h,
                   input			wire		[ 11:0 ]		addr_v,
                   input			wire						data_vld,
                   input			wire		[ 23:0 ]		distance_data,
                   output			wire		[ 15:0 ]		rgb_data);

localparam	red    = 16'd63488;
localparam	orange = 16'd64384;
localparam	yellow = 16'd65472;
localparam	green  = 16'd1024;
localparam	blue   = 16'd31;
localparam	indigo = 16'd18448;
localparam	purple = 16'd32784;
localparam	white  = 16'd65503;
localparam	black  = 16'd0;

parameter	NUM = 100;
reg			[ 19:0 ]			distance_data_r			;
reg			[ 15:0 ]			rgb_data_r			;
reg			[ 10:0 ]			data_r[NUM -1:0]			;
integer j;
integer i;
//寄存数据
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        distance_data_r <= 0;
    end
    else if(data_vld) begin
        distance_data_r <=distance_data[7:4]+ distance_data[11:8]*10 + distance_data[15:12] * 100 ;
    end
end

//数据打拍
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for (i = 0; i<NUM - 1;i=i+1 ) begin
            data_r[i] <= 0;
        end
    end
    else if(data_vld) begin
        data_r[0] <= distance_data_r;
        for (i = 1; i<NUM - 1;i=i+1 ) begin
            data_r[i] <= data_r[i-1];
        end
    end
end
reg			[ 10:0 ]			cnt			;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rgb_data_r = 0;
        cnt = 0;
    end
    else if(cnt == NUM) begin
        rgb_data_r = black;
        cnt = 0;
    end
    else if(addr_v > 470 && addr_v < 476 && addr_h >9 && addr_h < 625 ) begin //横坐标
        rgb_data_r = white;
        cnt = cnt;
    end
    else if(addr_h > 9 && addr_h <15 && addr_v >9 && addr_v <= 470) begin //纵坐标
        rgb_data_r = white;
        cnt = cnt;
    end
    else if(addr_h >20 && addr_h < 620 && addr_v >10 && addr_v < 470) begin  //打点
        if ( (cnt+1) * 3 == addr_h -20) begin
            if(data_r[cnt] == 470 - addr_v)begin
                rgb_data_r = red;
                cnt = cnt + 1;
            end
            else begin
                rgb_data_r = black;
                cnt = cnt + 1;
            end
        end
        else begin
            rgb_data_r = black;
            cnt = cnt;
        end
    end
    else begin
        rgb_data_r = black;
        cnt = cnt;
    end
end
assign rgb_data = rgb_data_r;
endmodule