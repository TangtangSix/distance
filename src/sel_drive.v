module sel_drive(
	input clk,
	input rst_n,
	
	output reg [5:0] sel
);
localparam state0 = 3'd0;
localparam state1 = 3'd1;
localparam state2 = 3'd2;
localparam state3 = 3'd3;
localparam state4 = 3'd4;
localparam state5 = 3'd5;

parameter	MAX_NUM = 1_000;

reg [2:0] current_state;
reg [2:0] next_state;
reg    [20:0]	  cnt; //时钟分频计数器
reg              flag;

//计数器
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		flag <= 1'b0;
		cnt <= 0;
	end
	else if(cnt == 0)begin//一轮计数完毕
		flag <= 1'b1;
		cnt <= 1;
	end
	else	begin 
		flag <= 1'b0;
		cnt <= (cnt + 1'b1) % MAX_NUM;//循环+1
	end
end
// 状态跳转
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		current_state <= state0;
	end
	else if(flag) begin
		current_state <= next_state;
	end
end


//状态判断
always @(*) begin
	if(!rst_n) begin
		next_state <= state0;
	end
	else if(flag) begin
		case(current_state)
			state0: begin
				next_state <= state1;
			end
			state1: begin
				next_state <= state2;
			end
			state2: begin
				next_state <= state3;
			end
			state3: begin
				next_state <= state4;
			end
			state4: begin
				next_state <= state5;
			end
			state5: begin
				next_state <= state0;
			end
			default:begin
				next_state <= state0;
			end
		endcase
	end
	else begin
		next_state <= next_state;
	end
end


//状态输出
always@(current_state) begin
	case (current_state)
		state0: begin
			sel <= 6'b011111;
		end
		state1: begin
			sel <= 6'b101111;
		end
		state2: begin
			sel <= 6'b110111;
		end
		state3: begin
			sel <= 6'b111011;
		end
		state4: begin
			sel <= 6'b111101;
		end
		state5: begin
			sel <= 6'b111110;
		end
		default:begin
			sel <= 6'b111111;
		end
	endcase


end
endmodule