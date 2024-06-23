`timescale 1ns / 1ps
`define DELAY 1

module N_bit_cla_adder_pipeline_optimized_autocompare_tb();
    parameter DATA_WID = 32;
    parameter clock_period = 10; // 10ns = 100MHz
    
    reg [DATA_WID-1:0] in1; 
    reg [DATA_WID-1:0] in2; 
    reg carry_in;     
    wire [DATA_WID-1:0] sum;
    wire carry_out;    
    reg clock, reset;

    reg [31:0] pass_count=0, fail_count=0; // record test results of automatic comparison
    reg [DATA_WID:0] correct_sum;
    reg [DATA_WID-1:0] in1_number, in2_number;
    reg carry_in_number;

    integer i=0;
    
    // Instantiate the design
    N_bit_cla_adder_pipeline_optimized #(DATA_WID) inst_cla(//AUTOINST
        // Inputs
        .clock(clock),
        .reset(reset),
        .in1(in1[DATA_WID-1:0]),
        .in2(in2[DATA_WID-1:0]),
        .carry_in(carry_in),        
        // Outputs
        .sum(sum[DATA_WID-1:0]),
        .carry_out(carry_out));
    
    initial begin
        in1 = 16'd0;
        in2 = 16'd0;
        carry_in = 1'b0;
        clock = 0;
        reset = 0;
        in1_number=0;
        in2_number=1;
        carry_in_number=0;
    end
    
    // generate a clock
    always begin
        # (clock_period/2) clock = ~clock;
    end
    
    initial begin
        @(posedge clock);
        reset <= #(`DELAY) 1;
        
        for(i=0; i<10; i=i+1) @(posedge clock); 
        
        reset <= #(`DELAY) 0;
        @(posedge clock);
        
        //first test pattern
        in1_number = 5;
        in2_number = 10;
        carry_in_number = 0;
        
        @(posedge clock);  
        in1 <= #(`DELAY) in1_number;
        in2 <= #(`DELAY) in2_number;
        carry_in <= #(`DELAY) carry_in_number;
        correct_sum <= #(`DELAY) in1_number + in2_number + carry_in_number;
        
        // reset adder in1/in2/carry_in to 0 in1/in2 will be registered at top level of cla adder 
        @(posedge clock); 
        in1 <= #(`DELAY) 0;
        in2 <= #(`DELAY) 0;
        carry_in <= #(`DELAY) 0;  
        
        // after one clock, sum/carry_out will be valid  
        @(posedge clock);

        /* 
        remember the adder output (sum/carry_out) is valid after "DELAY" time 
        ( that is the clock-to-output delay), 
        so compare to golden answer a little more than DELAY
        */
        #(`DELAY*2);
        // compare the sum with the expected sum
        if (sum == correct_sum[DATA_WID-1:0]) begin
            pass_count = pass_count + 1;
            $display("pass : at time %t,expected sum=%h, get sum=%h",$time(),correct_sum[DATA_WID-1:0],sum);     
        end
        else begin
            fail_count = fail_count + 1;    
            $display("error : at time %t,expected sum=%h, get sum=%h",$time(),correct_sum[DATA_WID-1:0],sum);
        end 
        
        // compare the carry_out with the expected carry_out
        if (carry_out == correct_sum[DATA_WID]) begin 
            pass_count = pass_count + 1;
            $display("pass : at time %t, expected carry_out=%d, get carry_out=%d",$time(),correct_sum[DATA_WID],carry_out);     
        end
        else begin
            fail_count = fail_count + 1;    
            $display("error : at time %t, expected carry_out=%d, get carry_out=%d",$time(),correct_sum[DATA_WID],carry_out);
        end  
        
        // second test, test  the carry_in=1
        in1_number = 32'h0000_ABCD;
        in2_number  = 32'h0000_1234;
        carry_in_number = 1;
        
        @(posedge clock); 
        in1 <= #(`DELAY) in1_number;
        in2 <= #(`DELAY) in2_number;
        carry_in <= #(`DELAY) carry_in_number;
        correct_sum <= #(`DELAY) in1_number + in2_number + carry_in_number;
        
        // reset adder in1/in2/carry_in to 0 in1/in2 will be registered at top level of cla adder 
        @(posedge clock);
        in1 <= #(`DELAY) 0;
        in2 <= #(`DELAY) 0;
        carry_in <= #(`DELAY)  0;
        
        // after one clock, sum/carry_out will be valid  
        @(posedge clock);

        /*
        remember the adder output (sum/carry_out) is valid after "DELAY" time 
        ( that is the clock-to-output delay) , 
        so compare to golden answer a little more than DELAY
        */
        #(`DELAY*2); 
        // compare the sum with the expected sum
        if (sum == correct_sum[DATA_WID-1:0]) begin
            pass_count = pass_count + 1;
            $display("pass : at time %t,expected sum=%h, get sum=%h",$time(),correct_sum[DATA_WID-1:0],sum);     
        end
        else begin
            fail_count = fail_count + 1;    
            $display("error : at time %t,expected sum=%h, get sum=%h",$time(),correct_sum[DATA_WID-1:0],sum);
        end 
        
        // compare the carry_out with the expected carry_out
        if (carry_out == correct_sum[DATA_WID]) begin 
            pass_count = pass_count + 1;
            $display("pass : at time %t, expected carry_out=%d, get carry_out=%d",$time(),correct_sum[DATA_WID],carry_out);     
        end
        else begin
            fail_count= fail_count + 1;    
            $display("error : at time %t, expected carry_out=%d, get carry_out=%d",$time(),correct_sum[DATA_WID],carry_out);
        end
  
        // 3rd test , test the carry_out , so in1 and in2 is the max 32 bit unsigned number
        in1_number = 32'hFFFF_FFFF;
        in2_number  = 32'hFFFF_FFFF;
        carry_in_number = 0;

        @(posedge clock); 
        in1 <= #(`DELAY) in1_number;
        in2 <= #(`DELAY) in2_number;
        carry_in <= #(`DELAY) carry_in_number;
        correct_sum <= #(`DELAY) in1_number + in2_number + carry_in_number;
        
        // reset adder in1/in2/carry_in to 0 in1/in2 will be registered at top level of cla adder
        @(posedge clock);  
        in1 <= #(`DELAY) 0;
        in2 <= #(`DELAY) 0;
        carry_in <= #(`DELAY) 0;  
        
        // after one clock, sum/carry_out will be valid  
        @(posedge clock);

        /*
        remember the adder output (sum/carry_out) is valid after "DELAY" time 
        ( that is the clock-to-output delay) , 
        so compare to golden answer a little more than DELAY
        */
        #(`DELAY*2); 
        // compare the sum with the expected sum
        if (sum == correct_sum[DATA_WID-1:0]) begin
            pass_count = pass_count + 1;
            $display("pass : at time %t,expected sum=%h, get sum=%h",$time(),correct_sum[DATA_WID-1:0],sum);     
        end
        else begin
            fail_count = fail_count + 1;    
            $display("error : at time %t,expected sum=%h, get sum=%h",$time(),correct_sum[DATA_WID-1:0],sum);
        end 
        
        // compare the carry_out with the expected carry_out
        if (carry_out == correct_sum[DATA_WID]) begin 
            pass_count = pass_count + 1;
            $display("pass : at time %t, expected carry_out=%d, get carry_out=%d",$time(),correct_sum[DATA_WID],carry_out);     
        end
        else begin
            fail_count = fail_count + 1;    
            $display("error : at time %t, expected carry_out=%d, get carry_out=%d",$time(),correct_sum[DATA_WID],carry_out);
        end
  
        @(posedge clock);
        $display("Test End");
        $display("pass_count=%d",pass_count);
        $display("fail_count=%d",fail_count);
        
        if (fail_count==0) 
            $display("YA! no error");
        else
            $display("Oh No, check error");  

        for(i=0; i<10; i=i+1) @(posedge clock); 
        
        $finish();  
    end 
    
 endmodule
