`timescale 1ns / 1ps

module net(
input logic[10:0] x,
input logic [10:0] y,
output logic [11:0] rgb
    );
     
     // Upper-left-hand corner
   parameter XLOC = 100;
   parameter YLOC = 100;
   // Dimensions
   parameter WIDTH = 100;
   parameter HEIGHT = 100;
   // RGB
   parameter COLOR = 12'hf0f;
   
   
   always_comb
   begin
   if((x>= XLOC) && (x<= XLOC+WIDTH) && (y>=YLOC) && (y<= YLOC + HEIGHT))
   rgb = COLOR*y[2]+ COLOR*y[3];
   
   else
   rgb = 0;
   
   end
endmodule