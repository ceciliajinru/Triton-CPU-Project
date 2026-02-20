/*
 *  hazard_controller.sv
 *  Author: Zifeng Zhang
 *  hazard_controller collects feedbacks from each stage and detect whether there are hazards in the pipeline.
 *  If there are hazard, it gennerate control signal to stall or flush each stage. 
 */
 `include "tmp_core.svh"
 module hazard_controller (
   
   alu_output_ifc.in alu_result,
   mem_d_pass_through_ifc.in i_w_d_mem_pass_through,

   load_pc_ifc.out load_pc,

	hazard_control_ifc.out i2i_hc,
	hazard_control_ifc.out i2a_hc,
	hazard_control_ifc.out a2m_hc
 );



   logic i_stall, i_flush;
   logic a_stall, a_flush;
   logic w_stall, w_flush;

   always_comb begin
      i_stall = 1'b0;
      i_flush = 1'b0;

      a_stall = 1'b0;
      a_flush = 1'b0;

      w_stall = 1'b0;
      w_flush = 1'b0;
      load_pc.we = 1'b0;

      
      if(i_w_d_mem_pass_through.is_jump) begin
         
         
         a_flush = 1'b1;
         load_pc.we = 1'b1;
         load_pc.new_pc = i_w_d_mem_pass_through.branch_target;
         $display("Jump target:%d", i_w_d_mem_pass_through.branch_target);
         
      end
      
      if(alu_result.branch_outcome == TAKEN) begin
         
         
         a_flush = 1'b1;
         load_pc.we = 1'b1;
         load_pc.new_pc = i_w_d_mem_pass_through.branch_target;
         $display("Branch target:%d", i_w_d_mem_pass_through.branch_target);
         
      end 

      if(i_w_d_mem_pass_through.is_mem_access) begin
         i_stall = 1'b1;
      end
         
   end

   always_comb begin

      i2i_hc.flush = 1'b0;
      i2i_hc.stall = i_stall;
      
      i2a_hc.flush = a_flush;
      i2a_hc.stall = a_stall;

      a2m_hc.flush = w_flush;
      a2m_hc.stall = w_stall;

   end



 endmodule