`define CYCLE_1SEC 48000000

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
reg [31:0] counter_1sec;
wire       period_1sec;
//
always @(posedge clk, negedge res_n)
begin
	if (~res_n)
		counter_1sec <= 32'h00000000;
	else if (period_1sec)
		counter_1sec <= 32'h00000000;
	else
		counter_1sec <= counter_1sec + 32'h00000001;
end
//
assign period_1sec =(counter_1sec == (`CYCLE_1SEC - 1));

//----------------------------
// Counter to make LED signal
//----------------------------
reg [2:0] counter_led;
reg direction;
//
always @(posedge clk, negedge res_n)
begin
	if (~res_n)
	begin
		counter_led <= 3'b001;
		direction <= 1'b0;
	end
	else if (period_1sec)
	begin
		if (direction)begin
			if(counter_led == 3'b001)begin
				counter_led <= 3'b010;
				direction <= 1'b0;
			end
			else
				counter_led <= counter_led >> 3'b001;
		end
		else begin
			if(counter_led == 3'b100)begin
				counter_led <= 3'b010;
				direction <= 1'b1;
			end
			else
				counter_led <= counter_led << 3'b001;
		end
	end
end
//
assign led = ~counter_led; // LED on by low level
endmodule
