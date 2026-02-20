/*
 * reg_file.sv
 * Author: Zifeng Zhang
 * 
 *
 */
`include "tmp_core.svh"

interface reg_file_output_ifc ();
	logic [`DATA_WIDTH - 1 : 0] rs1_data;
	logic [`DATA_WIDTH - 1 : 0] rs2_data;

	modport in  (input rs1_data, rs2_data);
	modport out (output rs1_data, rs2_data);
endinterface

module reg_file (
	

	// Input from decoder
	decoder_output_ifc.in i_decoded,

	// Input from write back stage
	write_back_ifc.in i_wb,
	memory_d_output_ifc.in i_mem_d,
	// Output data
	reg_file_output_ifc.out out
);

	logic [`DATA_WIDTH - 1 : 0] regs [32];

	assign out.rs1_data = i_decoded.uses_rs1 ? regs[i_decoded.rs1_addr] : '0;
	assign out.rs2_data = i_decoded.uses_rs2 ? regs[i_decoded.rs2_addr] : '0;

	// Don't need forward unit because of the design
	always_comb begin
		regs[0] = '0;

		if(i_wb.uses_rw)
		begin
			// $display("IS MEM ACCESS::%d", i_wb.is_mem_access);
			if(i_wb.is_mem_access) begin
				regs[i_wb.rw_addr] = i_mem_d.data;
			end else begin
				regs[i_wb.rw_addr] = i_wb.rw_data;
			end
		end

		$display("reg_a4::", regs[14]);
		$display("reg_a5::", regs[15]);
		$display("reg_a6::", regs[16]);
	end

	

endmodule
