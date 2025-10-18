`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: TEC
// Engineer: Carlos Andrey Morales Zamora
// 
// Create Date: 07.03.2025
// Design Name: 
// Module Name: ALU_DUT
// Project Name: tb_LabFPGA2
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_LabFPGA2;

	// Parameters
	parameter int WIDTH = 24;
	parameter int DIVIDER = 2;

	// Input signals
	logic clk = 0;
	logic rst;
	logic en_reg_i;
	logic sw_reg_b_i;
	logic slct_op_i;
	logic slct_byte_i;
	logic slct_sb_i;
	logic [3:0] cntrl_alu_i;
	logic [3:0] op_i;

	// Output signals
	logic [3:0] flag_o;
	logic [41:0] display_o;
	logic [1:0] counter_slct_op_o;
	logic [1:0] counter_slct_byte_o;
	logic sb_op_o;

	// Clock generation: 50 MHz (20 ns period)
	always #10 clk = ~clk;

	// Device Under Test (DUT)
	LabFPGA2 #(
		.WIDTH(WIDTH),
		.DIVIDER(DIVIDER)
	) dut (
		.clk_i(clk),
		.rst_i(rst),
		.en_reg_i(en_reg_i),
		.sw_reg_b_i(sw_reg_b_i),
		.slct_op_i(slct_op_i),
		.slct_byte_i(slct_byte_i),
		.slct_sb_i(slct_sb_i),
		.cntrl_alu_i(cntrl_alu_i),
		.op_i(op_i),
		.flag_o(flag_o),
		.display_o(display_o),
		.counter_slct_op_o(counter_slct_op_o),
		.counter_slct_byte_o(counter_slct_byte_o),
		.sb_op_o(sb_op_o)
	);
		
	// Task to load a 24-bit operand into the active register (A or B)
	task load_operand(input logic [23:0] operand);
		logic sw_sb;
		begin
			sw_sb = 0;
			for (int byte_idx = 1; byte_idx < 7; byte_idx++) begin
				op_i = operand[byte_idx*4-1 -: 4]; // Extract nibble from MSB to LSB
				#10;
				en_reg_i = 0;
				#40;
				en_reg_i = 1;
				if(!sw_sb) begin 
					// Toggle nibble selector (LSB to MSB)
					#10;
					slct_sb_i = 0;
					#40;
					slct_sb_i = 1;
				end else begin
					// Move to next byte
					#10;
					slct_byte_i = 0;
					#40;
					slct_byte_i = 1;
				end
				sw_sb = ~sw_sb;
				#10;
			end
			// Switch to next operand (e.g., from A to B, or B to Result)
			slct_op_i = 0;
			#40;
			slct_op_i = 1;
			#10;
		end
	endtask

	// Task to display the result and stop the simulation
	task show_result();
		begin
			#100;
			// Return selector to Operand A
			slct_op_i = 0;
			#40;
			slct_op_i = 1;
			#10;
			$stop;
		end
	endtask
		
	// Task to perform an ALU operation between A and B
	task calc(input logic [3:0] cntrl_alu, input logic [23:0] A, input logic [23:0] B);
		begin
			cntrl_alu_i = cntrl_alu;
			#20;
			// Load operand A
			load_operand(A);
			// Load operand B
			load_operand(B);
			// Display result
			show_result();
		end
	endtask

	// === Main test sequence ===
	initial begin
	
		// Initialize all control signals
		rst = 1;
		en_reg_i = 1;
		sw_reg_b_i = 0;
		slct_op_i = 1;
		slct_byte_i = 1;
		slct_sb_i = 1;
		cntrl_alu_i = 0;
		op_i = 0;
		#10;
		
		// Apply reset pulse
		rst = 0;
		#20;
		rst = 1;
		#30;
		
		// Test case 1: A = 0x005A5, B = 0x00A5A, operation = ADD (0)
		calc(4'd0, 24'h5A5, 24'hA5A);
		
		// Continue your code here....
		
		// Test case 2: A = 0x00xxx, B = 0x00xxx, operation = SUB (1)
		calc(4'd1, 24'hfff, 24'hfff);

		// Test case 3: A = 0x00fff, B = 0x00f0f, operation = AND (4)
		calc(4'd4, 24'hfff, 24'hf0f);
		
		// Test case 4: A = 0x000f0, B = 0x00f0f, operation = OR (5)
		calc(4'd5, 24'h0f0, 24'hf0f);

		// Test case 5: A = 0x000ff, B = 0x00008, operation = SLL (11)
		calc(4'd11, 24'h0ff, 24'h008);

		// Test case 6: A = 0x00ff0, B = 0x00008, operation = SRL (11)
		calc(4'd12, 24'hff0, 24'h008);

		$finish;
	end

endmodule
