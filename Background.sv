`timescale 1ns / 1ps

module Background(
input logic[10:0] x,
input logic [10:0] y,
output logic [11:0] rgb
    );
   //set parameters for the wall and net locations
   parameter TOP_WALL_Y = 128;
   parameter BOTTOM_WALL_Y = 512;
   parameter WALL_WIDTH = 799;
   parameter WALL_HEIGHT = 8;
   parameter WALL_X =0;
   parameter NET_X = 396;
   parameter NET_Y = 136;
   parameter NET_WIDTH = 8;
   parameter NET_HEIGHT = 376;
   
   
   logic [11:0] rgb1; logic [11:0] rgb2; logic[11:0] rgb3;
   
   //Create instnaces of the wall
   rectgen#(.XLOC(WALL_X), .YLOC(TOP_WALL_Y), .WIDTH(WALL_WIDTH), .HEIGHT(WALL_HEIGHT)) 
            TOPWALL(.x(x), .y(y), .rgb(rgb1));

   rectgen#(.XLOC(WALL_X), .YLOC(BOTTOM_WALL_Y), .WIDTH(WALL_WIDTH), .HEIGHT(WALL_HEIGHT)) 
            BOTTOMWALL(.x(x), .y(y), .rgb(rgb2));            
   
   
   //create the net

   net#(.XLOC(NET_X), .YLOC(NET_Y), .WIDTH(NET_WIDTH), .HEIGHT(NET_HEIGHT))
            NET(.x(x), .y(y), .rgb(rgb3));
   
    assign rgb = rgb1+rgb2+rgb3;
    

    
endmodule