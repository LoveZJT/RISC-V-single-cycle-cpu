`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/26 14:57:55
// Design Name: 
// Module Name: single_cycle_cpu
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


module single_cycle_cpu(clk,instr);
    input clk;
    output [31:0] instr;
    reg [31:0] pc;
    wire [31:0] new_pc;
    wire rd_byte_w_en;
    //wire [31:0] instr;
    initial begin
        pc = 0;
        //new_pc = 0;
    end
    always@(posedge clk) begin
        pc <= new_pc;
        end
    get_instr i1(pc,instr);
    control i2(clk,pc,instr,new_pc);
endmodule

module get_instr(
    input [31:0] pc,
    output reg [31:0] instr
    );
    (* ram_style="distributed" *)
    reg [31:0] instr_mem[7000:0];
    initial begin
        $readmemh("F:\\Project\\digital circuit\\single_cycle_cpu\\single_cycle_cpu.srcs\\ram.txt",instr_mem);
    end
    always@(*) begin
        instr<=instr_mem[pc[31:2]];
        $display("hello");
    end
endmodule

module control(
    input clk,
    input [31:0] pc,
    input [31:0] instr,
    output [31:0] new_pc
    );
    reg rd_byte_w_en;
    wire [31:0] rs_out;
    wire [31:0] rt_out;
    wire [31:0] rd_in;
    wire [31:0] ALU_out;
    wire [31:0] Shift_out;
    wire [31:0] B_in;
    reg [1:0] Shift_op;
    wire [4:0] Shift_amount;
    always@(*) begin
        if(instr[6:0]==7'b0110111 || instr[6:0]==7'b0010111 || instr[6:0]==7'b1101111 || instr[6:0]==7'b1100111 || instr[6:0]==7'b0010011 || instr[6:0]==7'b0110011)
            rd_byte_w_en = 1;
        else
            rd_byte_w_en = 0;
        if(instr[14:12] == 3'b001)
            Shift_op = 2'b00;
        else if(instr[14:12] == 3'b101 && instr[31:25] == 7'b0000000)
            Shift_op = 2'b01;
        else if(instr[14:12] == 3'b101 && instr[31:25] == 7'b0100000)
            Shift_op = 2'b10;
        else
            Shift_op = 2'b11;
    end
    //assign Shift_amount=instr[24:20];
    registers i3(rd_byte_w_en,instr[19:15],instr[24:20],instr[11:7],clk,rd_in,rs_out,rt_out);
    rd_in_pick i4(pc,instr[31:12],ALU_out,Shift_out,instr[6:0],instr[14:12],rd_in);
    B_pick i5(rt_out,instr,B_in);
    Shift_amount_pick i6(rt_out,instr[6:0],instr[24:20],Shift_amount);
    Shift i7(Shift_amount,Shift_op,rs_out,Shift_out);
    ALU i8(rs_out,B_in,instr[6:0],instr[14:12],instr[31:25],ALU_out);
    next_pc i9(pc,instr,ALU_out,rs_out,new_pc);
endmodule

module registers(
    input rd_byte_w_en,
    input [4:0] rs_addr,
    input [4:0] rt_addr,
    input [4:0] rd_addr,
    input clk,
    input [31:0] rd_in,
    output [31:0] rs_out,
    output [31:0] rt_out
    );
    reg [31:0] registers[31:0];
    integer i;
    initial begin
        for(i = 0;i < 32;i = i + 1)
            registers[i] = 0;
        end
    always@(posedge clk) begin
        if(rd_byte_w_en==1 && rd_addr != 0)
            registers[rd_addr]<=rd_in;
    end
    assign rs_out=registers[rs_addr];
    assign rt_out=registers[rt_addr];
endmodule

module ALU(
    input [31:0] A_in,
    input [31:0] B_in,
    input [6:0] opcode,
    input [2:0] func3,
    input [6:0] func7,
    output reg [31:0] ALU_out
    );
    always@(*) begin
        case(opcode)
        7'b1100011: begin
            case(func3)
            3'b000: begin
                if(A_in == B_in)
                    ALU_out = 1;
                else
                    ALU_out = 0;
                end
            3'b001: begin
                if(A_in == B_in)
                    ALU_out = 0;
                else
                    ALU_out = 1;
                end
            3'b100: begin
                if($signed(A_in) < $signed(B_in))
                    ALU_out = 1;
                else
                    ALU_out = 0;
                end
            3'b101: begin
                if($signed(A_in) >= $signed(B_in))
                    ALU_out = 1;
                else
                    ALU_out = 0;
                end
            3'b110: begin
                if($unsigned(A_in) < $unsigned(B_in))
                    ALU_out = 1;
                else
                    ALU_out = 0;
                end
            3'b111: begin
                if($unsigned(A_in) >= $unsigned(B_in))
                    ALU_out = 1;
                else
                    ALU_out = 0;
                end
            default: begin
                ALU_out = 0;
                end
            endcase
            end
        7'b0010011: begin
            case(func3)
            3'b000: begin
                ALU_out = A_in + B_in;
                end
            3'b010: begin
                if($signed(A_in) < $signed(B_in))
                    ALU_out = 1;
                else
                    ALU_out = 0;
                end
            3'b011: begin
                if($unsigned(A_in) < $unsigned(B_in))
                    ALU_out = 1;
                else
                    ALU_out = 0;
                end
            3'b100: begin
                ALU_out = A_in ^ B_in;
                end
            3'b110: begin
                ALU_out = A_in | B_in;
                end
            3'b111: begin
                ALU_out = A_in & B_in;
                end
            default: begin
                ALU_out = 0;
                end
            endcase
            end
        7'b0110011: begin
            case(func3)
            3'b000: begin
                case(func7)
                7'b0000000: begin
                    ALU_out = A_in + B_in;
                    end
                7'b0100000: begin
                    ALU_out = A_in - B_in;
                    end
                default: begin
                    ALU_out = 0;
                    end
                endcase
                end
            3'b010: begin
                if($signed(A_in) < $signed(B_in))
                    ALU_out = 1;
                else
                    ALU_out = 0;
                end
            3'b011: begin
                if($unsigned(A_in) < $unsigned(B_in))
                    ALU_out = 1;
                else
                    ALU_out = 0;
                end
            3'b100: begin
                ALU_out = A_in ^ B_in;
                end
            3'b110: begin
                ALU_out = A_in | B_in;
                end
            3'b111: begin
                ALU_out = A_in & B_in;
                end
            default: begin
                ALU_out = 0;
                end
            endcase
            end
        default: begin
            ALU_out = 0;
            end
        endcase
    end
endmodule

module rd_in_pick(
    input [31:0] pc,
    input [19:0] imm,
    input [31:0] ALU_out,
    input [31:0] Shift_out,
    input [6:0] opcode,
    input [2:0] func3,
    output reg [31:0] Rd_in
    );
    always@(*) begin
        case(opcode)
        7'b0110111: begin
            Rd_in = imm << 12;
            end
        7'b0010111: begin
            Rd_in = pc + (imm << 12);
            end
        7'b1101111: begin
            Rd_in = pc + 4;
            end
        7'b1100111: begin
            Rd_in = pc + 4;
            end
        7'b0010011: begin
            case(func3)
            3'b001: begin
                Rd_in = Shift_out;
                end
            3'b101: begin
                Rd_in = Shift_out;
                end
            default: begin
                Rd_in = ALU_out;
                end
            endcase
            end
        7'b0110011: begin
            case(func3)
            3'b001: begin
                Rd_in = Shift_out;
                end
            3'b101: begin
                Rd_in = Shift_out;
                end
            default: begin
                Rd_in = ALU_out;
                end
            endcase
            end
        default: begin
            Rd_in = 0;
            end
        endcase
    end
endmodule

module B_pick(
    input [31:0] rt,
    input [31:0] instr,
    output reg [31:0] B_in
    );
    always@(*) begin
        case(instr[6:0])
        7'b1100011: begin
            //B_in = (instr[31] << 12) + (instr[30:25] << 5) + (instr[11:8] << 1) + (instr[7] << 11);
            B_in = rt;
            end
        7'b0010011: begin
            if(instr[31] == 0)
                B_in = instr[31:20];
            else
                B_in = instr[31:20] | 32'hfffff000;
            end
        7'b0110011: begin
            B_in = rt;
            end
        default: begin
            B_in = 0;
            end
        endcase
    end
endmodule

module Shift_amount_pick(
    input [31:0] rt,
    input [6:0] opcode,
    input [4:0] imm,
    output reg [4:0] Shift_amount
    );
    always@(*) begin
        case(opcode)
        7'b0010011: begin
            Shift_amount = imm;
            end
        7'b0110011: begin
            Shift_amount = rt[4:0];
            end
        default: begin
            Shift_amount = 0;
            end
        endcase
    end
endmodule

module Shift(
    input [4:0] Shift_amount,
    input [1:0] Shift_op,
    input [31:0] Shift_in,
    output reg [31:0] Shift_out
    );
    always@(*) begin
        case(Shift_op)
        2'b00: begin
            Shift_out = Shift_in << Shift_amount;
            end
        2'b01: begin
            Shift_out = Shift_in >> Shift_amount;
            end
        2'b10: begin
            if(Shift_in[31] == 0)
                Shift_out = Shift_in >> Shift_amount;
            else
                Shift_out = (Shift_in >> Shift_amount) | (32'hffffffff << (32 - Shift_amount));
            end
        default: begin
            Shift_out = 0;
            end
        endcase
    end
endmodule

module next_pc(
    input [31:0] pc,
    input [31:0] instr,
    input [31:0] ALU_out,
    input [31:0] rs,
    output reg [31:0] new_pc
    );
    reg [31:0] imm;
    always@(*) begin
        case(instr[6:0])
        /*7'b0010111: begin
            imm = 0;
            imm = instr[31:12];
            new_pc = pc + (imm << 12);
            end*/
        7'b1101111: begin
            imm = 0;
            imm = (instr[31] << 20) + (instr[30:21] << 1) + (instr[20] << 11) + (instr[19:12] << 12);
            new_pc = pc + imm;
            end
        7'b1100111: begin
            imm = 0;
            imm = instr[31:20];
            if(instr[31] == 1)
                imm = imm | 32'hfffff000;
            new_pc = rs + imm;
            end
        7'b1100011: begin
            imm = 0;
            imm = (instr[31] << 12) + (instr[30:25] << 5) + (instr[11:8] << 1) + (instr[7] << 11);
            if(imm[12] == 1)
                imm = imm | 32'hfffff000;
            if(ALU_out == 1)
                new_pc = pc + imm;
            else
                new_pc = pc + 4;
            end
        default: begin
            new_pc = pc + 4;
            end
        endcase
    end
endmodule
