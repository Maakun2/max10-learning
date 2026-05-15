`define CYCLE_1sec 48000000; //;これいらない

//モジュール宣言
module led{ //()かっこはこっち 
	input wire clk //,をを忘れてる
	input wire res_n //,をを忘れてる
	output reg[2:0] led
	}//()かっこはこっち 
	
//1秒の計算
reg[31:0] counter_1sec;
wire period_1sec;

always(posedge clk, negedge res_n); //(のまえに@が必要
begin
	if(res_n) //res_nは立ち下がりは0なので~で反転させる
		counter_1sec <= 32'h00000000;
	else if(period_1sec)
		counter_1sec <= 32'h00000000;
	else
		counter_1sec <= counter_1sec + 32'h00000001;
end

assign period_1sec <= (counter_1sec == (CYCLE_1sec - 1)); //<=ではなく=，またdefineの値を使うときは`が必要

//ledの処理
reg[2:0] counter_led;
reg direction;

always(posedge clk, negedge res_n);
begin
	if(res_n)
	begin
		counter_led <= 3'b001;
		direction <= 1'b0;
	end
	else
	begin
		if(counter_1sec) //ledの更新にはperiod_1secをつかう
		begin
			if(direction)
			begin
				if(couter_led == 3'b001)
				begin
					counter_led <= 3'b010;
					direction <= 1'b0;
				end
				else
					counter_led <= counter_led >> 3'b001;
					
			end
			else
			begin
				if(counter_led == 3'b100)
				begin
					counter_led <= 3'b010;
					direction <= 1'b1; 
				end
				else
					counter_led <= couter_led << 3'b001;
			end
		end
	end
end

assign counter_led = ~counter_led; //代入先はled
