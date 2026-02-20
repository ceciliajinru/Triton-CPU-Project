/*
 *  memory_i.sv
 *  Author: Zifeng Zhang
 *
 *  Memory access for instruction fetch
 *  
 *
 */
 `include "tmp_core.svh"

module memory_i (
    
	pc_ifc.in i_pc_current,

    memory_output_ifc.out out

);
    logic [`DATA_WIDTH - 1 : 0] mem_arr_i [0:1024]; //1024 instructions

    always_comb begin
        
        if(^i_pc_current.pc !== 1'bx) begin
            if (^mem_arr_i[i_pc_current.pc[9:0]] === 1'bx) begin
                out.done = 1'b1;
                out.data = 'x;
            end else begin
                out.data = mem_arr_i[i_pc_current.pc[9:0]];
            end
        
        

            $display("pc:%d, data:%h, done:%d", i_pc_current.pc, out.data, out.done);
        end

    end

    initial begin
        // Read the hex file into the memory array
        $readmemh("rtl/mem_i.hex", mem_arr_i);
        for (int i = 0; i < 1024; i++) begin
                $display("%b", mem_arr_i[i][6:0]);
        end
    end


endmodule