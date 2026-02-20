/*
 * pipeline_registers.sv
 * Author: Zifeng Zhang
 * 
 *
 * These are the pipeline registers between each two adjacent stages. 
 * 
 * 
 */
 `include "tmp_core.svh"
 module pr_i2a (
	input clk,    
	input rst_n,  

	hazard_control_ifc.in i_hc,

	pc_ifc.in  i_pc,
	pc_ifc.out o_pc,

	memory_output_ifc.in  i_inst,
	memory_output_ifc.out o_inst
);
	always_ff @(posedge clk)
	begin
		if(~rst_n)
		begin
			o_pc.pc <= '0;
			o_inst.data <= '0;
		end
		else
		begin
			if (!i_hc.stall)
			begin
				if (i_hc.flush)
				begin
					o_pc.pc <= '0;
					o_inst.data <= '0;
				end
				else
				begin
					o_pc.pc <= i_pc.pc;
					o_inst.data <= i_inst.data;
					o_inst.done <= i_inst.done;
				end
			end
		end
	end
endmodule

module pr_a2w (
	input clk,    // Clock
	input rst_n,  // Synchronous reset active low

	hazard_control_ifc.in i_hc,
	memory_d_input_ifc.in  i_w_d_input,
	mem_d_pass_through_ifc.in  i_w_pass_through,
	
	memory_d_input_ifc.out o_w_d_input,
	write_back_ifc.out o_w_write_back,
	output done
);
	logic done_int;

	assign done = done_int;

	always_ff @(posedge clk)
	begin
		if(~rst_n)
		begin
			

			
			o_w_d_input.mem_action <= READ;
			o_w_d_input.addr <= '0;
			o_w_d_input.data <= '0;

			
			o_w_write_back.uses_rw <= 1'b0;
			o_w_write_back.rw_addr <= zero;
			o_w_write_back.rw_data <= '0;
			done_int <= 0;
		end
		else
		begin
			if (!i_hc.stall)
			begin
				if (i_hc.flush)
				begin
					
					o_w_d_input.mem_action <= READ;
					o_w_d_input.addr <= '0;
					o_w_d_input.data <= '0;

					
					o_w_write_back.uses_rw <= 1'b0;
					o_w_write_back.rw_addr <= zero;
					o_w_write_back.rw_data <= '0;
				end
				else
				begin
					o_w_d_input.mem_action <= i_w_d_input.mem_action;
					o_w_d_input.addr <= i_w_d_input.addr;
					o_w_d_input.data <= i_w_d_input.data;

					o_w_write_back.is_mem_access <= i_w_pass_through.is_mem_access;
					o_w_write_back.uses_rw <= i_w_pass_through.uses_rw;
					o_w_write_back.rw_addr <= i_w_pass_through.rw_addr;
					o_w_write_back.rw_data <= i_w_pass_through.alu_result;
					
					o_w_d_input.done    <= i_w_pass_through.done;
					done_int 			<= i_w_pass_through.done;
				end
			end
		end
	end
endmodule

