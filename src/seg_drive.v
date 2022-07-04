module seg_drive(input			wire						clk,
                 input			wire						rst_n,
                 input			wire						data_vld,
                 input			wire		[ 23:0 ]		display_data,
                 input			wire		[ 5:0 ]		    sel,
                 output			reg		[ 7:0 ]				seg);
        

    localparam	ZERO  = 7'b100_0000;
    localparam	ONE   = 7'b111_1001;
    localparam	TWO   = 7'b010_0100;
    localparam	THREE = 7'b011_0000;
    localparam	FOUR  = 7'b001_1001;
    localparam	FIVE  = 7'b001_0010;
    localparam	SIX   = 7'b000_0010;
    localparam	SEVEN = 7'b111_1000;
    localparam	EIGHT = 7'b000_0000;
    localparam	NINE  = 7'b001_0000;
    localparam	N     = 7'b010_1011;
    localparam	P     = 7'b000_1111;

    reg			[ 23:0 ]			display_data_r			;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            display_data_r <= 0;
        end
        else if(data_vld) begin
            display_data_r <= display_data;
        end
    end

    reg dot;
    reg [ 3:0 ] num;

    always@( * ) begin
        case( sel )
            6'b111_110: begin
                // num = display_data / 100000 % 10;
                num = display_data_r[23 :20];
                dot = 1;                
            end
            6'b111_101: begin
                // num = display_data / 10000 % 10;
                num = display_data_r[19 : 16];
                dot = 1;
            end
            6'b111_011: begin
                // num = display_data / 1000 % 10;
                num = display_data_r[15 : 12];
                dot = 1;
            end
            6'b110_111: begin
                // num = display_data / 100 % 10;
                num = display_data_r[11 :8];
                dot = 0;
            end
            6'b101_111: begin
                //num = display_data / 10 % 10;
                num = display_data_r[7 :4];
                dot = 1;
            end
            6'b011_111: begin
                //num = display_data % 10;
                num = display_data_r[3 :0];
                dot = 1;
            end
            default num = 4'hf; 
        endcase
    end
    
    always @ ( * ) begin
        case( num )
            4'd0:   seg = {dot,ZERO}; // 匹配到后参考共阳极真值表
            4'd1:   seg = {dot,ONE};
            4'd2:   seg = {dot,TWO};
            4'd3:   seg = {dot,THREE};
            4'd4:   seg = {dot,FOUR};
            4'd5:   seg = {dot,FIVE};
            4'd6:   seg = {dot,SIX};
            4'd7:   seg = {dot,SEVEN};
            4'd8:   seg = {dot,EIGHT};
            4'd9:   seg = {dot,NINE};
            default : seg = {1'b0,ZERO};
        endcase
    end
endmodule
