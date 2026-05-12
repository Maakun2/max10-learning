`define CYCLE_SEC0 24000000
`define CYCLE_SEC1 48000000
`define CYCLE_SEC2 96000000

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
reg [31:0] counter_sec0;
wire       period_sec0;
reg [31:0] counter_sec1;
wire       period_sec1;
reg [31:0] counter_sec2;
wire       period_sec2;
//
always @(posedge clk, negedge res_n)
begin
	if (~res_n)
	begin
		counter_sec0 <= 32'h00000000;
		counter_sec1 <= 32'h00000000;
		counter_sec2 <= 32'h00000000;
	end
	else
	begin
		if (period_sec0)
			counter_sec0 <= 32'h00000000;
		else
			counter_sec0 <= counter_sec0 + 32'h00000001;
			
		if (period_sec1)
			counter_sec1 <= 32'h00000000;
		else
			counter_sec1 <= counter_sec1 + 32'h00000001;
			
		if (period_sec2)
			counter_sec2 <= 32'h00000000;
		else
			counter_sec2 <= counter_sec2 + 32'h00000001; 
	end	
end
//
assign period_sec0 =(counter_sec0 == (`CYCLE_SEC0 - 1));
assign period_sec1 =(counter_sec1 == (`CYCLE_SEC1 - 1));
assign period_sec2 =(counter_sec2 == (`CYCLE_SEC2 - 1));


//----------------------------
// Counter to make LED signal
//----------------------------
reg counter_led0;
reg counter_led1;
reg counter_led2;
//
always @(posedge clk, negedge res_n)
begin
	if (~res_n)
	begin
		counter_led0 <= 1'b0;
		counter_led1 <= 1'b0;
		counter_led2 <= 1'b0;

	end
	else
	begin
		if (period_sec0)
			counter_led0 <= counter_led0 + 1'b1;
			
		if(period_sec1)
			counter_led1 <= counter_led1 + 1'b1;
		
		if (period_sec2)
			counter_led2 <= counter_led2 + 1'b1;
		end
end
//
assign led[0] = ~counter_led0; // LED on by low level
assign led[1] = ~counter_led1; 
assign led[2] = ~counter_led2;

endmodule
