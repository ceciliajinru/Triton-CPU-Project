`timescale 1ns/1ps
`include "tmp_core.svh"
module tb;
    
    logic clk;
    logic rst_n;
    logic done;
    
    tmp_core tmp (
        .clk(clk),
        .rst_n(rst_n),
        .done(done)
    );

    initial begin
        clk = 0;
        rst_n = 0;

        #5 clk = 1;

        #5 rst_n = 1;
        #5 clk = 0;
        


        
        forever #5 clk = ~clk;
        
    end

    always_ff @(posedge clk) begin
        if(done) begin

            $stop;
        end
    end

    

    
endmodule