/*
 * glue_circuits.sv
*/
`include "tmp_core.svh"
module decode_glue(
    decoder_output_ifc.in i_decoded,
	reg_file_output_ifc.in i_reg_data,

    alu_input_ifc.out o_alu_input,
	alu_pass_through_ifc.out o_alu_pass_through
);

    always_comb
    begin
		o_alu_input.alu_ctl = i_decoded.alu_ctl;
		o_alu_input.op1 =     i_reg_data.rs1_data;
        o_alu_input.op2 =     i_decoded.uses_immediate
			? i_decoded.immediate
			: i_reg_data.rs2_data;


        o_alu_pass_through.is_branch = i_decoded.is_branch;
		o_alu_pass_through.is_jump = i_decoded.is_jump;
		o_alu_pass_through.is_jump_reg = i_decoded.is_jump_reg;
		o_alu_pass_through.branch_target = i_decoded.branch_target;

		
		
		o_alu_pass_through.is_mem_access = i_decoded.is_mem_access;
		o_alu_pass_through.mem_action =    i_decoded.mem_action;
		o_alu_pass_through.mem_write_data         =     i_reg_data.rs2_data;

		o_alu_pass_through.uses_rw =       i_decoded.uses_rd;
		o_alu_pass_through.rw_addr =       i_decoded.rd_addr;
		o_alu_pass_through.done    =       i_decoded.done;

    end

endmodule

module ex_glue (
	alu_output_ifc.in i_alu_output,
	alu_pass_through_ifc.in i_alu_pass_through,

	
	memory_d_input_ifc.out o_a_w_mem_input,
	mem_d_pass_through_ifc.out o_a_w_mem_pass_through
);

	always_comb
	begin
		o_a_w_mem_input.mem_action = i_alu_pass_through.mem_action;
		o_a_w_mem_input.addr =       i_alu_output.result[`ADDR_WIDTH - 1 : 0];
		o_a_w_mem_input.data =       i_alu_pass_through.mem_write_data;
		o_a_w_mem_input.done =       i_alu_pass_through.done;

		o_a_w_mem_pass_through.is_branch = i_alu_pass_through.is_branch;
		o_a_w_mem_pass_through.is_jump = i_alu_pass_through.is_jump;
		o_a_w_mem_pass_through.is_jump_reg = i_alu_pass_through.is_jump_reg;
		o_a_w_mem_pass_through.branch_target = i_alu_pass_through.branch_target;



		o_a_w_mem_pass_through.is_mem_access = i_alu_pass_through.is_mem_access;
		o_a_w_mem_pass_through.alu_result =    i_alu_output.result;
		o_a_w_mem_pass_through.uses_rw =       i_alu_pass_through.uses_rw;
		o_a_w_mem_pass_through.rw_addr =       i_alu_pass_through.rw_addr;
		o_a_w_mem_pass_through.done    =  	   i_alu_pass_through.done;
	end
endmodule