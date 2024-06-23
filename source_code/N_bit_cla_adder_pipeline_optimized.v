`timescale 1ns / 1ps

module N_bit_cla_adder_pipeline_optimized (clock, reset, in1, in2, carry_in, sum, carry_out);
    parameter DATA_WID = 32;

    input clock, reset;
    input [DATA_WID - 1:0] in1;
    input [DATA_WID - 1:0] in2;
    input carry_in;
    output [DATA_WID - 1:0] sum;
    output carry_out;    
    
    // for pipeline cla, input registers
    reg [DATA_WID - 1:0] in1_reg;
    reg [DATA_WID - 1:0] in2_reg;
    reg carry_in_reg;
    // for pipeline cla, output registers
    reg [DATA_WID - 1:0] sum_reg;
    reg carry_out_reg;
    
    wire [DATA_WID - 1:0] sum_wire;
    //wire carry_out_wire;
    /*
    In order to optimize the pipeline cla,  
    select the sum and carry_out of the high-16 bits cla to be 0 or 1, 
    depanding on the carry_out of the low-16 bits cla
    */
    // the carry_out of the low-16 bits cla 
    wire carry_out_wire_low;

    // the sum of the high-16 bits cla to be 0 or 1 
    wire [DATA_WID/2 - 1:0] sum_wire_high_0;
    wire [DATA_WID/2 - 1:0] sum_wire_high_1;

    // the carry_out of the high-16 bits cla to be 0 or 1 
    wire carry_out_wire_high_0;
    wire carry_out_wire_high_1;
    
    // output
    assign  sum = sum_reg;
    assign  carry_out = carry_out_reg;   
    
    always@(posedge clock) begin
        if (reset) begin // synchronous reset
            in1_reg <=#1 0;
            in2_reg <=#1 0;
            carry_in_reg <=#1 0;
            sum_reg <=#1 0;
            carry_out_reg <=#1 0;
        end
        // for pipeline cla, input/output are written into input/output register
        else begin
            in1_reg <=#1 in1;
            in2_reg <=#1 in2;
            carry_in_reg <=#1 carry_in;            
            //sum_reg <=#1 sum_wire;
            //carry_out_reg <=#1 carry_out_wire;
            /*
            According to the carry_out of the low-16 bits cla, 
            select the sum and carry_out of the high-16 bits cla to be 0 or 1
            */
            // the sum of low-16 bits cla 
            sum_reg[DATA_WID/2 - 1:0] <=#1 sum_wire[DATA_WID/2 -1:0];  
            
            if (carry_out_wire_low == 1'b0) begin
                // the sum of the high-16 bits cla to be 0
                sum_reg[DATA_WID-1:DATA_WID/2] <=#1 sum_wire_high_0;
                // the carry_out of the high-16 bits cla to be 0 
                carry_out_reg <=#1 carry_out_wire_high_0;
            end
            else begin
                // the sum of the high-16 bits cla to be 1
                sum_reg[DATA_WID-1:DATA_WID/2] <=#1 sum_wire_high_1;
                // the carry_out of the high-16 bits cla to be 1 
                carry_out_reg <=#1 carry_out_wire_high_1;
            end       
        end      
    end
    
    /*
    N_bit_cla_adder N_bit_cla_adder_inst(
        .in1(in1_reg), 
        .in2(in2_reg), 
        .carry_in(carry_in_reg), 
        .sum(sum_wire), 
        .carry_out(carry_out_wire));
    */
    // low-16 bits cla
    N_bit_cla_adder #(16) N_bit_cla_adder_inst_low(
        .in1(in1_reg[DATA_WID/2 - 1:0]), 
        .in2(in2_reg[DATA_WID/2 - 1:0]), 
        .carry_in(carry_in_reg), 
        .sum(sum_wire[DATA_WID/2 - 1:0]), 
        .carry_out(carry_out_wire_low));

    // high-16 bits cla_0
    N_bit_cla_adder #(16) N_bit_cla_adder_inst_high_0(
        .in1(in1_reg[DATA_WID-1:DATA_WID/2]), 
        .in2(in2_reg[DATA_WID-1:DATA_WID/2]), 
        .carry_in(1'b0), 
        .sum(sum_wire_high_0), 
        .carry_out(carry_out_wire_high_0));

    // high-16 bits cla_1 
    N_bit_cla_adder #(16) N_bit_cla_adder_inst_high_1(
        .in1(in1_reg[DATA_WID-1:DATA_WID/2]), 
        .in2(in2_reg[DATA_WID-1:DATA_WID/2]), 
        .carry_in(1'b1), 
        .sum(sum_wire_high_1), 
        .carry_out(carry_out_wire_high_1));

endmodule
