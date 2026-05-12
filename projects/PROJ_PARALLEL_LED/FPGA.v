`define CYCLE_SEC1 48000000
`define CYCLE_SEC2 24000000

//--------------------
// Top of the FPGA
//--------------------
module FPGA
(
	input wire clk,			// 48Mhz Clock
	input wire res_n,			//Reset Switch
	output wire [2:0]led	//LED Output
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
assign period_1sec =(counter_1sec == (`CYCLE_SEC1 - 1));

reg [31:0] counter_sec2;
wire       period_sec2;
//
always @(posedge clk, negedge res_n)
begin
	if (~res_n)
		counter_sec2 <= 32'h00000000;
	else if (period_sec2)
		counter_sec2 <= 32'h00000000;
	else
		counter_sec2 <= counter_sec2 + 32'h00000001;
end
//
assign period_sec2 =(counter_sec2 == (`CYCLE_SEC2 - 1));

//----------------------------
// Counter to make LED signal
//----------------------------
reg counter_led1;
//
always @(posedge clk, negedge res_n)
begin
	if (~res_n)
		counter_led1 <= 1'b0;
	else if (period_1sec)
		counter_led1 <= counter_led1 + 1'b1;
end
//
assign led[0] = ~counter_led1; // LED on by low level

reg counter_led2;
//
always @(posedge clk, negedge res_n)
begin
	if (~res_n)
		counter_led2 <= 1'b0;
	else if (period_sec2)
		counter_led2 <= counter_led2 + 1'b1;
end
//
assign led[1] = ~counter_led2; // LED on by low level
assign led[2] = 1'b1
endmodule
