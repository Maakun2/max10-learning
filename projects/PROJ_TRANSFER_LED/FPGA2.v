`define CYCLE_1SEC 48000000 //1秒を48Mhzとする

//--------------------
// Top of the FPGA
//--------------------
module FPGA
(
	input wire clk,			// 48Mhz Clock
	input wire res_n,			//Reset Switch
	output wire [2:0] led	//LED Output
);

//-----------------------------
// Counter to makeS 1sec Period
//-----------------------------
	reg [31:0] counter_1sec; //1秒を数えるカウンター 
wire       period_1sec; //1秒たったかを判定する
//
always @(posedge clk, negedge res_n)
begin
	if (~res_n)
		counter_1sec <= 32'h00000000; //リセットされたらカウンターを0に戻す
	else if (period_1sec)
		counter_1sec <= 32'h00000000; //1秒立ったらカウンターを0に戻す
	else
		counter_1sec <= counter_1sec + 32'h00000001; //カウンターを1づつ増やしていく
end
//
	assign period_1sec =(counter_1sec == (`CYCLE_1SEC - 1)); //counter_1secが47999999なら(1秒)ならperiod_1secが1になる(０秒から数えるから-1)

//----------------------------
// Counter to make LED signal
//----------------------------
reg [2:0] counter_led; //1ed用レジスタBGRの順になっている(0点灯，1消灯)
reg direction; //ledがどちらにシフトしているかを表すフラグ(0左，1右)

//
always @(posedge clk, negedge res_n) //clkが立ち上がったとき，またはres_nが立ち下がったときに実行される
begin
	if (~res_n) 
	begin
		counter_led <= 3'b001; //リセットされたときはR点灯
		direction <= 1'b0; //かつ左方向
	end
	else if (period_1sec)
	begin
		if (direction)
		begin
			if(counter_led == 3'b001) 
			begin
				counter_led <= 3'b010; //1秒たちかつ右方向に進んでいてかつ赤点灯なら緑点灯にする
				direction <= 1'b0; //かつ左方向にする
			end
			else
				counter_led <= counter_led >> 3'b001; //1秒たちかつ右方向に進んでいるならledを1右にシフトする
		end
		else begin
			if(counter_led == 3'b100)　
			begin
				counter_led <= 3'b010; //1秒たちかつ左方向にすすでおりかつ青点灯なら緑点灯にする
				direction <= 1'b1; //かつ右方向にする
			end
			else
				counter_led <= counter_led << 3'b001; //1秒たちかつ左方向に進んでいるならledを左にシフトする
		end
	end
end
//
assign led = ~counter_led; // LED on by low level
endmodule
