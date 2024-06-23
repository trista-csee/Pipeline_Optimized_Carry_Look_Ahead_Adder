`timescale 1ns / 1ps
`define DELAY #10

// carry look-ahead adder
module N_bit_cla_adder (in1, in2, carry_in, sum, carry_out);
    parameter DATA_WID = 32;

    input [DATA_WID - 1:0] in1;
    input [DATA_WID - 1:0] in2;
    input carry_in;
    output [DATA_WID - 1:0] sum;
    output carry_out;  
    
    wire [DATA_WID - 1:0] gen;
    wire [DATA_WID - 1:0] pro;
    wire [DATA_WID:0] carry_tmp;
    
    //assign {carry_out, sum} = in1 + in2 + carry_in;
    genvar j, i;
    generate
        //assume carry_tmp in is zero
        assign carry_tmp[0] = carry_in;
        
        //carry generator
        for (j = 0; j < DATA_WID; j = j + 1) begin: carry_generator
            assign gen[j] = in1[j] & in2[j];
            assign pro[j] = in1[j] | in2[j];
            assign carry_tmp[j+1] = gen[j] | pro[j] & carry_tmp[j];
        end
        
        //carry out 
        assign carry_out = carry_tmp[DATA_WID];
        
        //calculate sum 
        //assign sum[0] = in1[0] ^ in2 ^ carry_in;
        for (i = 0; i < DATA_WID; i = i+1) begin: sum_without_carry
            assign sum[i] = in1[i] ^ in2[i] ^ carry_tmp[i];
        end 
    endgenerate
    
endmodule
