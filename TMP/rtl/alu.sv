/*
 *  alu.sv
 *  Author: Zifeng Zhang
 *
 *  Defines the input and output interface of ALU of A(decode execution) stage.
 *  ALU can do ADD, SUB, AND, OR, XOR, NOR, NOP and branch resulution
 *
 */
 `include "tmp_core.svh"
interface alu_input_ifc ();
	
	tmp_core_pkg::AluCtl alu_ctl;
	logic signed [`DATA_WIDTH - 1 : 0] op1;
	logic signed [`DATA_WIDTH - 1 : 0] op2;

	modport in  (input alu_ctl, op1, op2);
	modport out (output alu_ctl, op1, op2);
endinterface

interface alu_output_ifc ();
	
	logic [`DATA_WIDTH - 1 : 0] result;
	tmp_core_pkg::BranchOutcome branch_outcome;

	modport in  (input result, branch_outcome);
	modport out (output result, branch_outcome);
endinterface

module alu (
	alu_input_ifc.in in,
	alu_output_ifc.out out
);

	always_comb
	begin
		
		out.result = '0;
		out.branch_outcome = NOT_TAKEN;
		
		case (in.alu_ctl)
			ALUCTL_NOP:  out.result = '0;
			ALUCTL_ADD:  out.result = in.op1 + in.op2;
			ALUCTL_SUB:  out.result = in.op1 - in.op2;
			ALUCTL_AND:  out.result = in.op1 & in.op2;
			ALUCTL_OR:   out.result = in.op1 | in.op2;
			ALUCTL_XOR:  out.result = in.op1 ^ in.op2;
			ALUCTL_NOR:  out.result = ~(in.op1 | in.op2);
			ALUCTL_BGE: out.branch_outcome = in.op1 >= signed'(0) ? TAKEN : NOT_TAKEN;
			ALUCTL_BEQ: out.branch_outcome = in.op1 == signed'(0) ? TAKEN : NOT_TAKEN;
		endcase
		$display("ALU op1:%d, ALU op2:%d, ALU result:%d", in.op1, in.op2, out.result);
	end
	
endmodule