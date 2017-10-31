`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/26 15:30:15
// Design Name: 
// Module Name: single_cycle_cpu_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module single_cycle_cpu_sim();
    reg clk;
    wire [31:0] instr;
    //wire [31:0] pc;
    single_cycle_cpu single_cycle_cpu0(
        .clk(clk),
        .instr(instr)
        //.pc(pc)
        );
    initial begin
        clk=1'b0;
        forever #20 clk=~clk;
    end
endmodule
