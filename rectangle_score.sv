`timescale 1ns / 1ps


module rectangle_score(
input logic[10:0] x,
input logic [10:0] y,
input logic data,  //whether the segment is on or off for that score
output logic [11:0] rgb
    );
    
     // Upper-left-hand corner
  parameter XLOC = 100;
  parameter YLOC = 100;
  // Dimensions
  parameter WIDTH = 100;
  parameter HEIGHT = 100;
  // RGB
  parameter COLOR = 12'hfff;
  
  
  always_comb
  begin
  if((x>= XLOC) && (x<= XLOC+WIDTH) && (y>=YLOC) && (y<= YLOC + HEIGHT) && data)
  rgb = COLOR;
  
  else
  rgb = 0;
  
  end
endmodule
