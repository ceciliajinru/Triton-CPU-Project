/*
 *  memory_i.sv
 *  Author: Zifeng Zhang
 *
 *  Memory access for data access
 *  
 *
 */
`include "tmp_core.svh"

interface memory_d_input_ifc ();
	tmp_core_pkg::MemAccessType mem_action;

	logic [`ADDR_WIDTH - 1 : 0] addr;
	logic [`DATA_WIDTH - 1 : 0] data;
    logic done;

	modport in  (input mem_action, addr, data, done);
	modport out (output mem_action, addr, data, done);
endinterface

interface memory_d_output_ifc ();
    logic [`DATA_WIDTH - 1 : 0] data;
    

    modport in  (input data);
	modport out (output data);
endinterface

module memory_d (
    // Request
	memory_d_input_ifc.in in,
    // Response 
    memory_d_output_ifc.out out
);
    logic [`DATA_WIDTH - 1 : 0] mem_arr_d [0:1024]; //1024 mem entries
    int file_handle;

    always_comb begin
        if(in.done) begin
            file_handle = $fopen("mem_d.hex", "w");
            if (file_handle == 0) begin
                $display("Error: Failed to open file for writing!!!!!");
                $stop;
            end
            $display("Write to mem_d.hex");
            for (int i = 0; i < 1024; i++) begin
                $fdisplay(file_handle, "%h", mem_arr_d[i]);
                // $display("final mem_d addr:%d, data:%d", i,mem_arr_d[i]);
            end

        end else begin
            
        end
    
        
        if(in.mem_action == READ) begin

            if (^mem_arr_d[in.addr[9:0]] === 1'bx) begin
            end else begin
                out.data = mem_arr_d[in.addr[9:0]];
                $display("mem_d addr:%d, data:%d", in.addr[9:0], out.data);
            end
        end else begin
            
            mem_arr_d[in.addr[9:0]] = in.data;
            // $display("mem_d addr:%d, data:%d", in.addr[9:0], in.data);
        end
        
    end
    

    initial begin
        // $readmemh("memory_d.hex", mem_arr_d);
        // for (int i = 0; i < 1024; i++) begin
        //     mem_arr_d[i] = 0;  // Example data
        // end
    end


endmodule