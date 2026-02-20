/*
 *  decoder.sv
 *  Author: Zifeng Zhang
 *  Decoder decode an instruction to control signals.
 *  
 */
 `include "tmp_core.svh"
 interface decoder_output_ifc ();
	
	tmp_core_pkg::AluCtl alu_ctl;
	logic is_jump;
	logic is_jump_reg;
	logic is_branch;
	logic [`ADDR_WIDTH - 1 : 0] branch_target;

	logic is_mem_access;
	tmp_core_pkg::MemAccessType mem_action;

	logic uses_rs1;
	tmp_core_pkg::TmpReg rs1_addr;

	logic uses_rs2;
	tmp_core_pkg::TmpReg rs2_addr;

	logic uses_immediate;
	logic [`DATA_WIDTH - 1 : 0] immediate;

	logic uses_rd;
	tmp_core_pkg::TmpReg rd_addr;

	logic done;

	modport in  (input alu_ctl, is_jump, is_jump_reg, is_branch,
		branch_target, is_mem_access, mem_action, uses_rs1, rs1_addr, 
		uses_rs2, rs2_addr, uses_immediate, immediate, uses_rd, rd_addr, done);
	modport out (output alu_ctl, is_jump, is_jump_reg, is_branch,
		branch_target, is_mem_access, mem_action, uses_rs1, rs1_addr, 
		uses_rs2, rs2_addr, uses_immediate, immediate, uses_rd, rd_addr, done);
endinterface

module decoder (
	pc_ifc.in i_pc,
	memory_output_ifc.in i_inst,

	decoder_output_ifc.out out
);
	task rs1;
		begin
			// Only set uses_rs1 if it is not register zero
			out.uses_rs1 = |i_inst.data[19:15];
			out.rs1_addr = tmp_core_pkg::TmpReg'(i_inst.data[19:15]);
		end
	endtask

	task rs2;
		begin
			// Only set uses_rs2 if it is not register zero
			out.uses_rs2 = |i_inst.data[24:20];
			out.rs2_addr = tmp_core_pkg::TmpReg'(i_inst.data[24:20]);
		end
	endtask

	task rd;
		begin
			// Only set uses_rd if it is not register zero
			out.uses_rd = |i_inst.data[11:7];
			out.rd_addr = tmp_core_pkg::TmpReg'(i_inst.data[11:7]);
		end
	endtask

	task imm_i_type;
		input [31:0] ins;
		begin
			logic [11:0] imm12;
			imm12 = ins[31:20];

			out.uses_immediate = 1'b1;
			out.immediate = `DATA_WIDTH'(signed'(imm12));
		end
	endtask

	task imm_JALR;
		input [31:0] ins;
		begin
			logic [11:0] imm12;
			imm12 = ins[31:20];

			out.uses_immediate = 1'b1;
			out.immediate = `DATA_WIDTH'(signed'(imm12));
			out.branch_target = `ADDR_WIDTH'(out.immediate);
		end
	endtask

	task imm_s_type;
		input [31:0] ins;
		begin
			logic [11:0] imm12;
			imm12 = {ins[31:25], ins[11:7]};

			out.uses_immediate = 1'b1;
			out.immediate = `DATA_WIDTH'(signed'(imm12));
		end
	endtask

	task imm_b_type;
		input [31:0] ins;
		begin
			logic [12:0] imm13;
			imm13 = {ins[31], ins[7], ins[30:25], ins[11:8], 1'b0};
			out.branch_target = i_pc.pc + signed'(imm13);
			out.is_branch = 1'b1;

			// $display("i_pc.pc:%d, add:%b", i_pc.pc, signed'(imm13));
		end
	endtask

	task imm_j_type;
        input [31:0] ins;
        begin
            logic [20:0] imm21;
            imm21 = {ins[31], ins[19:12], ins[20], ins[30:21], 1'b0};
			$display("i_pc.pc:%d, add:%b", i_pc.pc, signed'(imm21));
            out.branch_target = i_pc.pc + signed'(imm21);

			out.is_jump = 1'b1;
        end
    endtask

	always_comb
	begin
		// Set defaults to nop
		
		out.alu_ctl = ALUCTL_NOP;
		out.is_jump = 1'b0;
		out.is_jump_reg = 1'b0;
		out.branch_target = '0;
		out.is_mem_access = 1'b0;
		out.mem_action = READ;

		out.uses_rs1 = 1'b0;
		out.rs1_addr = zero;

		out.uses_rs2 = 1'b0;
		out.rs2_addr = zero;

		out.uses_immediate = 1'b0;
		out.immediate = '0;

		out.uses_rd = 1'b0;
		out.rd_addr = zero;

		// $display("ins:%b", i_inst.data[6:0]);

		case(i_inst.data[6:0])
			7'b0010011: // ADDI/SUBI/SLLI // I-Type
			begin
				rs1();
				rd();
				imm_i_type(i_inst.data);
				case(i_inst.data[14:12])
					3'b000: // ADDI
					begin
						out.alu_ctl = ALUCTL_ADD;
					end
				endcase
				
			end

			7'b0110011: // ADD/SUB/SLL  // R-Type
			begin
				rs1();
				rs2();
				rd();
				case(i_inst.data[31:25])
					7'b0000000: // ADD
					begin
						case(i_inst.data[14:12])
							3'b000:
							begin
								out.alu_ctl = ALUCTL_ADD;
							end
						endcase
					end

					7'b0100000:
					begin
						case(i_inst.data[14:12])
							3'b000:
							begin
								out.alu_ctl = ALUCTL_SUB;
							end
						endcase
					end
				endcase
			end

			7'b1100011: // Branch  // B-Type
			begin
				rs1();
				rs2();
				imm_b_type(i_inst.data);
				out.is_branch = 1'b0;

				case(i_inst.data[14:12])
					3'b101:
					begin
						out.alu_ctl = ALUCTL_BGE;
					end
				endcase

				case(i_inst.data[14:12])
					3'b000:
					begin
						out.alu_ctl = ALUCTL_BEQ;
					end
				endcase
			end

			7'b0000011: // Load // I-Type
			begin
				rs1();
				rd();
				imm_i_type(i_inst.data);
				case(i_inst.data[14:12])
					3'b010: // LW
					begin
						out.is_mem_access = 1'b1;
						out.alu_ctl = ALUCTL_ADD;
						out.mem_action = READ;
					end
				endcase
			end

			7'b0100011: // Store // S-Type
			begin
				rs1();
				rs2();
				imm_s_type(i_inst.data);
				case(i_inst.data[14:12])
					3'b010: // SW
					begin
						out.is_mem_access = 1'b1;
						out.alu_ctl = ALUCTL_ADD;
						out.mem_action = WRITE;
					end
				endcase
			end

			7'b1101111: // JAL // J-Type
			begin
				rd();
				imm_j_type(i_inst.data);
				out.alu_ctl = ALUCTL_NOP;
			end

			7'b1100111: // JALR // I-Type
			begin
				rs1();
				rd();
				imm_JALR(i_inst.data);
				out.alu_ctl = ALUCTL_NOP;
			end

			default:
			begin
				$display("OPERATION NOT SUPPORTED. PC=0x%x", i_pc.pc);
			end
			
		endcase





	end

	always_comb begin
		out.done = i_inst.done;
	end


endmodule