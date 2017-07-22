`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:09:28 06/21/2016 
// Design Name: 
// Module Name:    MIO_BUS 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module MIO_BUS(
	input clk,
	input rst,
	input[3:0]BTN,
	input[15:0]SW,
	input mem_w,
	input[31:0]Cpu_data2bus,				//data from CPU
	input[31:0]addr_bus,
	input[31:0]ram_data_out,
	input[15:0]led_out,
	input[31:0]counter_out,
	input counter0_out,
	input counter1_out,
	input counter2_out,

	output reg[31:0]Cpu_data4bus,				//write to CPU
	output reg[31:0]ram_data_in,				//from CPU write to Memory
	output reg[13:0]ram_addr,						//Memory Address signals
	output reg data_ram_we,
	output reg GPIOf0000000_we,
	output reg GPIOe0000000_we,
	output reg counter_we,
	output reg[31:0]Peripheral_in
);
	reg data_ram_rd,GPIOf0000000_rd,GPIOe0000000_rd,counter_rd;
	
	always @ * begin
		data_ram_we = 0;
		data_ram_rd = 0;
		counter_we = 0;
		GPIOf0000000_we = 0;
		GPIOf0000000_rd = 0;
		GPIOe0000000_we = 0;
		GPIOe0000000_rd = 0;
		counter_rd = 0;
		ram_addr = 13'h0;
		ram_data_in = 32'h0;
		Peripheral_in = 32'h0;
		case(addr_bus[31:28])
			4'h0:begin
				 data_ram_we = mem_w;
				 ram_addr = addr_bus[15:2];
				 ram_data_in = Cpu_data2bus;
				 data_ram_rd = ~mem_w;
			end
				 
			4'he:begin
				GPIOe0000000_we = mem_w;
				Peripheral_in = Cpu_data2bus;
				GPIOe0000000_rd = ~mem_w;
			end
			
			4'hf:begin
				if(addr_bus[2])begin
					counter_we = mem_w;
					Peripheral_in = Cpu_data2bus;
					counter_rd = ~mem_w;
				end
				else begin
					GPIOf0000000_we = mem_w;
					Peripheral_in = Cpu_data2bus;
					GPIOf0000000_rd = ~mem_w;
				end
			end
		endcase 
	end 
  
	always @ * begin
		casex({data_ram_rd,GPIOe0000000_rd,counter_rd,GPIOf0000000_rd})
			4'b1xxx:Cpu_data4bus = ram_data_out;
			4'bx1xx:Cpu_data4bus = counter_out;
			4'bxx1x:Cpu_data4bus = counter_out;
			4'bxxx1:Cpu_data4bus = {counter0_out,counter1_out,counter2_out,17'b0,BTN[3:0],SW[7:0]};
			default :Cpu_data4bus = 32'h0;    
		endcase
	end			 
endmodule