module beep_dirve (
    input			wire						clk,
    input			wire						rst_n,
    input			wire						beep_vld,
    input			wire						data_vld,
    input			wire		[ 23:0 ]		distance_data,
    output			reg						    beep
);

parameter	MAX_DISTANCE = 20;
parameter	MIN_DISTANCE = 10;
parameter	MAX_TIME = 50_000_000;
reg			[ 27:0 ]			cnt			        ;
wire		[ 27:0 ]			delay			    ;
wire		[ 19:0 ]			distance			;
reg			[ 23:0 ]			distance_data_r			;
// wire			[ 19:0 ]			distance_r			;

//寄存数据
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        distance_data_r <= 0;
    end
    else if(data_vld) begin
        distance_data_r <= distance_data;
    end
end
// 根据距离设置翻转频率
assign distance = distance_data_r[11:8] + distance_data_r[15:12] * 10 + distance_data_r[19:16] * 100 + distance_data_r[23:20] *1000;
assign delay =  ((distance ) + 1) * 200_000;

// // led
always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        cnt <= 0;
    end
    else if ( cnt >= delay  ) begin
        cnt <= 0;
    end
    else begin
        cnt <= cnt + 1; 
    end 
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        beep <= 1;
    end
    else if(~beep_vld) begin
        beep <= 1;
    end
    else if(distance <= MAX_DISTANCE && distance >= MIN_DISTANCE && cnt == 1 && beep_vld) begin
        beep <= ~ beep;
    end
    else if(distance < MIN_DISTANCE && beep_vld) begin
        beep <= 0;
    end
    else if(distance > MAX_DISTANCE) begin
        beep <= 1;
    end
    else begin
        beep <= beep;
    end
end

endmodule //beep_dirve