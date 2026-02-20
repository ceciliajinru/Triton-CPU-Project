/*
 *  tmp_core_interfaces.sv
 *  Author: Zifeng Zhang
 *  
 *  Interfaces for input and output for units
 */
 `include "tmp_core.svh"

interface load_pc_ifc();
	logic we;
    logic [`ADDR_WIDTH - 1 : 0] new_pc;
    modport in  (input we, new_pc);
	modport out (output we, new_pc);
endinterface

interface pc_ifc ();
	logic [`ADDR_WIDTH - 1 : 0] pc;

	modport in  (input pc);
	modport out (output pc);
endinterface

interface memory_output_ifc ();
    logic [`DATA_WIDTH - 1 : 0] data;
	logic done;

    modport in  (input data, done);
	modport out (output data, done);
endinterface

interface hazard_control_ifc ();
	
	logic flush;	
	logic stall;	
	

	modport in  (input flush, stall);
	modport out (output flush, stall);
endinterface

interface alu_pass_through_ifc ();
	logic is_jump;
	logic is_branch;
	logic is_jump_reg;
	logic [`ADDR_WIDTH - 1 : 0] branch_target;
	
	
	

	logic is_mem_access;
	tmp_core_pkg::MemAccessType mem_action;
	logic [`DATA_WIDTH - 1 : 0] mem_write_data;
	

	logic uses_rw;
	tmp_core_pkg::TmpReg rw_addr;
	logic done; 

	modport in  (input is_jump, is_branch, is_jump_reg, branch_target, is_mem_access, mem_action, mem_write_data, uses_rw, rw_addr, done);
	modport out (output is_jump, is_branch, is_jump_reg, branch_target, is_mem_access, mem_action, mem_write_data, uses_rw, rw_addr, done);
endinterface

interface mem_d_pass_through_ifc ();
	logic is_jump;
	logic is_branch;
	logic is_jump_reg;
	logic [`ADDR_WIDTH - 1 : 0] branch_target;

	logic is_mem_access;
	tmp_core_pkg::MemAccessType mem_action;
	logic [`DATA_WIDTH - 1 : 0] alu_result;

	logic uses_rw;
	tmp_core_pkg::TmpReg rw_addr;
	logic done;

	modport in  (input is_jump, is_branch, is_jump_reg, branch_target, is_mem_access, mem_action, alu_result, uses_rw, rw_addr, done);
	modport out (output is_jump, is_branch, is_jump_reg, branch_target, is_mem_access, mem_action, alu_result, uses_rw, rw_addr, done);
endinterface


interface write_back_ifc ();
	logic uses_rw;	// Write Enable
	tmp_core_pkg::TmpReg rw_addr;
	logic [`DATA_WIDTH - 1 : 0] rw_data;
	logic is_mem_access;
	logic done;

	modport in  (input uses_rw, rw_addr, rw_data, is_mem_access, done);
	modport out (output uses_rw, rw_addr, rw_data, is_mem_access, done);
endinterface