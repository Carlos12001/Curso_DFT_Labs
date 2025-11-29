`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: TEC
// Engineer: Carlos Andrey Morales Zamora
// 
// Testbench for LabFPGA2_BIST (BIST-enabled ALU)
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_LabFPGA3;

  // Parameters
  parameter int WIDTH = 24;
  parameter int DIVIDER = 2;

  // Inputs
  logic clk = 0;
  logic rst;
  logic en_reg_i;
  logic sw_reg_b_i;
  logic slct_op_i;
  logic [3:0] cntrl_alu_i;

  // Outputs
  logic [3:0] flag_o;
  logic [41:0] display_o;
  logic [1:0] counter_slct_op_o;

  // Clock generation: 50 MHz → 20 ns period
  always #10 clk = ~clk;

  // DUT instance
  LabFPGA3 #(
    .WIDTH(WIDTH),
    .DIVIDER(DIVIDER)
  ) dut (
    .clk_i(clk),
    .rst_i(rst),
    .en_reg_i(en_reg_i),
    .sw_reg_b_i(sw_reg_b_i),
    .slct_op_i(slct_op_i),
    .cntrl_alu_i(cntrl_alu_i),
    .flag_o(flag_o),
    .display_o(display_o),
    .counter_slct_op_o(counter_slct_op_o)
  );

  // Access internal MISR signature through hierarchical reference
  wire [WIDTH-1:0] signature;
  assign signature = dut.signature;   // muestra la señal interna del MISR

  // ==============================================================
  // TASK: Run one iteration of the BIST
  // ==============================================================
  task run_BIST(input logic [3:0] alu_op);
    begin
	cntrl_alu_i = alu_op; // current operation (e.g., 0=ADD)
	en_reg_i = 0;

	// Capture operating A
	#10;
	en_reg_i = 1;
	#20;
	en_reg_i = 0;
	#10;
	// Switch to next operand 
	slct_op_i = 1;
	#20;
	slct_op_i = 0;
	// Capture operating B
	#10;
	en_reg_i = 1;
	#20;
	en_reg_i = 0;
	#10;
	// Switch to next operand 
	slct_op_i = 1;
	#20;
	slct_op_i = 0;
	// Capture RESULT for MISR
	#10;
	en_reg_i = 1;
	#20;
	en_reg_i = 0;
	#10;
	// Switch to next operand 
	slct_op_i = 1;
	#20;
	slct_op_i = 0;
	#100;
    end
  endtask

  // ==============================================================
  // MAIN TEST
  // ==============================================================
  initial begin
    // Initialization
    rst = 1;
    en_reg_i = 0;
    sw_reg_b_i = 0;
    slct_op_i = 0;
    cntrl_alu_i = 0;
    #10;

    // Reset
    rst = 0;
    #40;
    rst = 1;
    #40;

	// Continue your code here....
		
	run_BIST(4'd0);
	run_BIST(4'd4);
	run_BIST(4'd5);


	
	$stop;
    $finish;
  end

endmodule
