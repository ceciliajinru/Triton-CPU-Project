/*
 *  tmp_core.sv
 *  Author: Zifeng Zhang
 *  The core module for tmpTri.
 *  This is a 3-stage RISC-V pipeline architecture.
 *  It has I, A, W stages:
 *      I: instruction fetch, register access
 *      A: decode, execute
 *      W: data access, write back
 *  
 */
`include "tmp_core.svh"

module tmp_core (
    input clk, // Clock
    input rst_n, // reset active low
    output done
);

    
    // Interfaces
    // I stage
    
    pc_ifc if_pc_current();
	pc_ifc if_pc_next();
    memory_output_ifc if_i_mem_output();


    // A stage
    // Decoder
    decoder_output_ifc dec_decoder_output();
	pc_ifc i2a_pc();
    memory_output_ifc i2a_inst();
	

    //ALU

    mem_d_pass_through_ifc a_w_pass_through();

    write_back_ifc w_write_back();

    

    

    reg_file_output_ifc dec_reg_file_output();

    alu_input_ifc dec_alu_input();
    alu_output_ifc ex_alu_output();

    alu_pass_through_ifc dec_alu_pass_through();

    memory_d_input_ifc w_d_mem_input();

    memory_d_output_ifc w_d_mem_output();

    memory_d_input_ifc a_w_input(); 
    memory_d_output_ifc mem_d_output();


    //Hardzard control
    hazard_control_ifc i2i_hc();
    hazard_control_ifc i2a_hc();
    hazard_control_ifc a2m_hc();

    load_pc_ifc load_pc();


    
    // ==================================================================
    // I Stage
    // I Stage - instruction fetch, memaccess to instructions
    // ==================================================================
    fetch_unit FETCH_UNIT(
        .clk, .rst_n,

        .i_hc               (i2i_hc),
        .i_load_pc          (load_pc),

        .o_pc_current       (if_pc_current),
		.o_pc_next          (if_pc_next)
    );

    memory_i MEMORY_I(

        .i_pc_current       (if_pc_current),
        .out                (if_i_mem_output)
        
    );

    // I to A
    pr_i2a PR_I2A(
        .clk, .rst_n,
		.i_hc(i2a_hc),

		.i_pc               (if_pc_current),     
        .o_pc               (i2a_pc),
		.i_inst             (if_i_mem_output), 
        .o_inst             (i2a_inst)
        

    );

    // A Stage
    // A Stage - decode
    decoder DECODER(
        .i_pc(i2a_pc),
		.i_inst(i2a_inst),

		.out(dec_decoder_output)
    );

    reg_file REG_FILE(
		
		.i_decoded(dec_decoder_output),
		.i_wb(w_write_back), // Write back 
        .i_mem_d(w_d_mem_output),

		.out(dec_reg_file_output)
	);

    decode_glue DEC_GLUE(
		.i_decoded          (dec_decoder_output),
		.i_reg_data         (dec_reg_file_output),

		.o_alu_input        (dec_alu_input),
		.o_alu_pass_through (dec_alu_pass_through)
	);


    // A Stage - execute
    alu ALU(
		.in(dec_alu_input),
		.out(ex_alu_output)

	);

    ex_glue EX_GLUE (
		.i_alu_output           (ex_alu_output),
		.i_alu_pass_through     (dec_alu_pass_through),

		.o_a_w_mem_input        (a_w_input),
        .o_a_w_mem_pass_through (a_w_pass_through)
	);

    // A to W 
    pr_a2w PR_A2W (
		.clk, .rst_n,
		.i_hc(a2m_hc),

		.i_w_d_input       (a_w_input),
		.i_w_pass_through  (a_w_pass_through),

		.o_w_d_input         (w_d_mem_input),
		.o_w_write_back    (w_write_back),
        .done
	);
    // Mem access
    memory_d MEM_D (
        .in(w_d_mem_input),
        .out(w_d_mem_output)
    );


    // Hazard controll
    hazard_controller HAZARD_CONTROLLER (
        .alu_result                 (ex_alu_output),
        .i_w_d_mem_pass_through     (a_w_pass_through),
        .load_pc                    (load_pc),
        .i2i_hc                     (i2i_hc),
        .i2a_hc                     (i2a_hc),
        .a2m_hc                     (a2m_hc)

    );

    
    

    


    

    
    
endmodule
