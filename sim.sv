`timescale 1ns / 1ps
module sim;

   // Inputs
   reg clk;
   reg reset;
   reg serve;
   reg miss_l;
   reg miss_r;
   
   // Outputs
   wire srv_r;
   wire srv_l;
   wire visible;

   
   // Instantiate the Device Under Verification (DUV)
    controlUnitFSM duv(.clk(clk), .reset(reset), .serve(serve), .miss_l(miss_l), .miss_r(miss_r), .srv_r(srv_r), .srv_l(srv_l), .visible(visible));
        
   always begin
      clk = 0; #10;
      clk = 1; #10;
   end

   initial begin
      // Initialize Inputs
      reset = 1;
      serve = 0;
      miss_l = 0;
      miss_r = 0;
      
      @(posedge clk) #1;  // wait for first clock edge
      
      reset = 0;
      
      repeat(2)@(posedge clk) #1;
      serve=1;
      @(posedge clk) #1;
      serve=0;
      repeat(2)@(posedge clk) #1;
      miss_r=1;
      repeat(2) @(posedge clk) #1;
      serve=1;
      @(posedge clk) #1;
      miss_r=0; 
      serve=0; 
      $stop;
   end
      
endmodule
