`timescale 1ns / 1ps


module score_board(
input logic[10:0] x,
input logic [10:0] y,
input logic [8:0] segment, //each bit corresponds to a segment 
output logic [11:0] rgb
    );
    
    logic [11:0]rgb_0;
    logic [11:0]rgb_1;
    logic [11:0]rgb_2;
    logic [11:0]rgb_3;
    logic [11:0]rgb_4;
    logic [11:0]rgb_5;
    logic [11:0]rgb_6;
    logic [11:0]rgb_7;
    logic [11:0]rgb_8;
    
    
    parameter S_SIDE =5;
    parameter L_SIDE = 30;
    parameter XLOC= 50;
    parameter YLOC= 50;
    
    assign rgb= rgb_0|rgb_1|rgb_2|rgb_3|rgb_4|rgb_5|rgb_6|rgb_7|rgb_8;
    
    //A
    rectangle_score#(.XLOC(XLOC), .YLOC(YLOC), .WIDTH(L_SIDE), .HEIGHT(S_SIDE)) segA(.x(x), .y(y), .data(segment[0]), .rgb(rgb_0));
    //B
    rectangle_score#(.XLOC(XLOC+L_SIDE), .YLOC(YLOC+S_SIDE), .WIDTH(S_SIDE), .HEIGHT(L_SIDE)) segB(.x(x), .y(y), .data(segment[1]), .rgb(rgb_1));
    //C    
    rectangle_score#(.XLOC(XLOC+ L_SIDE), .YLOC(YLOC+2*S_SIDE+L_SIDE), .WIDTH(S_SIDE), .HEIGHT(L_SIDE)) segC(.x(x), .y(y), .data(segment[2]), .rgb(rgb_2));
    //D
    rectangle_score#(.XLOC(XLOC), .YLOC(YLOC+2*S_SIDE+2*L_SIDE), .WIDTH(L_SIDE), .HEIGHT(S_SIDE)) segD(.x(x), .y(y), .data(segment[3]), .rgb(rgb_3));
    //E
    rectangle_score#(.XLOC(XLOC-S_SIDE), .YLOC(YLOC+2*S_SIDE+L_SIDE), .WIDTH(S_SIDE), .HEIGHT(L_SIDE)) segE(.x(x), .y(y), .data(segment[4]), .rgb(rgb_4));
    //F
    rectangle_score#(.XLOC(XLOC-S_SIDE), .YLOC(YLOC+S_SIDE), .WIDTH(S_SIDE), .HEIGHT(L_SIDE)) segF(.x(x), .y(y), .data(segment[5]), .rgb(rgb_5));
    //G
    rectangle_score#(.XLOC(XLOC), .YLOC(YLOC+S_SIDE+L_SIDE), .WIDTH(L_SIDE), .HEIGHT(S_SIDE)) segG(.x(x), .y(y), .data(segment[6]), .rgb(rgb_6));
    //H
    rectangle_score#(.XLOC(XLOC-L_SIDE), .YLOC(YLOC+S_SIDE), .WIDTH(S_SIDE), .HEIGHT(L_SIDE)) segH(.x(x), .y(y), .data(segment[7]), .rgb(rgb_7));
    //I
    rectangle_score#(.XLOC(XLOC-L_SIDE), .YLOC(YLOC+2*S_SIDE+L_SIDE), .WIDTH(S_SIDE), .HEIGHT(L_SIDE)) segI(.x(x), .y(y), .data(segment[8]), .rgb(rgb_8));
    
endmodule
