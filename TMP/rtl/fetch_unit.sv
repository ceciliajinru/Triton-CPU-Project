/*
 *  fetch_unit.sv
 *  Author: Zifeng Zhang
 *  This module provide pc to decoder to fetch the next instruction.
 *  
 */
`include "tmp_core.svh"

module fetch_unit (
	input clk,    // Clock
	input rst_n,  

	// Stall
	hazard_control_ifc.in i_hc,

	// Load pc 
	load_pc_ifc.in i_load_pc,

	
	pc_ifc.out o_pc_current,
	pc_ifc.out o_pc_next
);
	always_comb
	begin
		if (!i_hc.stall)
			o_pc_next.pc = i_load_pc.we
				? i_load_pc.new_pc
				: o_pc_current.pc + `ADDR_WIDTH'd1; // pc+1 for memory in file, change later
		else
			o_pc_next.pc = o_pc_current.pc;
		
		// $display("next pc:", o_pc_next.pc);
	end

	always_ff @(posedge clk)
	begin
		if(~rst_n)
			o_pc_current.pc <= '0; // Start at 0	
		else
		begin
			o_pc_current.pc <= o_pc_next.pc;
			// $display("pc:", o_pc_current.pc);
			$display("curr pc:%d, %d, %d", o_pc_current.pc, i_load_pc.we, i_load_pc.new_pc);
				
		end
	end



endmodule