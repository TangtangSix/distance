module key_debounce #(parameter KEY_W = 3,TIME_20MS = 1000_000)(
	input					clk		,
	input					rst_n	,
	input		[KEY_W-1:0]	key_in 	,
	
	output	reg	[KEY_W-1:0]	key_out	 //检测到按下，输出一个周期的高脉冲，其他时刻为0
);
	
//信号定义
	reg		[19:0]		cnt		;
	wire				add_cnt	;
	wire				end_cnt	;
	reg					add_flag;
	
	reg		[KEY_W-1:0]	key_r0	;//同步按键输入
	reg		[KEY_W-1:0]	key_r1	;//打拍
	wire	[KEY_W-1:0]	nedge	;//检测下降沿
	
//计数器  检测到下降沿的时候，开启计数器延时20ms
	always @(posedge clk or negedge rst_n)begin 
		if(!rst_n)begin 
			cnt <= 0;
		end
		else if(add_cnt)begin 
			if(end_cnt)
				cnt <= 0;
			else 
				cnt <= cnt + 1;
		end  		
	end 
	assign add_cnt = add_flag;
	assign end_cnt = add_cnt && cnt == TIME_20MS-1;
	
	//检测到下降沿的时候，拉高计数器计数使能信号，延时结束时，再拉低使能信号
	always @(posedge clk or negedge rst_n)begin 
		if(!rst_n)begin 
			add_flag <= 1'b0;
		end 
		else if(nedge)begin 
			add_flag <= 1'b1;
		end 
		else if(end_cnt)begin 
			add_flag <= 1'b0;
		end 
	end 
	
	//同步按键输入，并打一拍，以检测下降沿
	always @(posedge clk or negedge rst_n)begin 
		if(!rst_n)begin 
			key_r0 <= {KEY_W{1'b1}};
			key_r1 <= {KEY_W{1'b1}};
		end 
		else begin 
			key_r0 <= key_in;//同步
			key_r1 <= key_r0;//打拍
		end 
	end
	assign nedge = ~key_r0 & key_r1;
		
	//延时20ms结束的时钟周期，输出按键的状态，若按下输出一个周期的高脉冲，否则输出0
	always@(posedge clk or negedge rst_n)begin 
		if(~rst_n)begin 
			key_out <= 0;
		end 
		else begin 
			key_out <= end_cnt?~key_r1:0;
		end 
	end 
	
	
endmodule 
