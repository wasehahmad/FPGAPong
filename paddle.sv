`timescale 1ns / 1ps

module paddle(
input logic clk, input logic reset,
input logic en,
input logic [9:0] x,
input logic [9:0] y,
input logic [9:0]pad,
input logic [9:0] ball_x,
input logic [9:0] ball_y,
output logic tophit,
output logic midhit,
output logic bothit,
output logic [11:0] rgb );

parameter XLOC = 50; // location on reset
parameter YLOC = 294;
parameter WIDTH = 10; // dimension
parameter HEIGHT = 60;
parameter COLOR = 12'hfff; // output color
parameter TOP_BOUND = 136;
parameter BOTTOM_BOUND =452;
parameter left =0;
parameter right =0;  //whether its the left paddle or the right paddle
parameter YSPEED =3;
parameter BALL_SIZE=10;

logic [9:0]currentY;

//create the paddle and occupy the space on the screen
always_comb
begin
if((x>= XLOC) && (x<= XLOC+WIDTH) && (y>currentY) && (y< currentY + HEIGHT))
   rgb = COLOR;
   
else
   rgb = 0;
end

always_ff@(posedge clk)
begin

    if(reset)begin
        currentY<=pad;
        midhit<=0;
        tophit<=0;
        bothit<=0;
    end
    
    else begin
    
///////////////////////////////////////////////////////////////    

        
        //if the paddle is the right paddle
        if(right && en && ((ball_x+BALL_SIZE)>=(XLOC)) && ((ball_x+BALL_SIZE)<799))begin
            if((ball_y+BALL_SIZE)>=currentY && (ball_y+BALL_SIZE/2)<=(currentY+(HEIGHT/3)))begin
                tophit<=1;
            end
            if((ball_y+BALL_SIZE/2)>(currentY+(HEIGHT/3)) && (ball_y+BALL_SIZE/2)<(currentY+(2*HEIGHT/3)))begin
                midhit <=1; 
            end
            if((ball_y+BALL_SIZE/2)>=(currentY+(2*HEIGHT/3)) && (ball_y)<= (currentY+HEIGHT))begin
                bothit<=1;
            end
  
        end
        
        //if the paddle is the left paddle
        else if(left && en && (ball_x<=(XLOC+WIDTH)) && (ball_x>XLOC))begin
            if((ball_y+BALL_SIZE)>=currentY && (ball_y+BALL_SIZE/2)<=(currentY+(HEIGHT/3)))begin
                tophit<=1;
            end
            if((ball_y+BALL_SIZE/2)>(currentY+(HEIGHT/3)) && (ball_y+BALL_SIZE/2)<(currentY+(2*HEIGHT/3)))begin
                midhit <=1; 
            end
            if((ball_y+BALL_SIZE/2)>=(currentY+(2*HEIGHT/3)) && (ball_y)<= (currentY+HEIGHT))begin
                bothit<=1;
            end
        end      
        else begin
            bothit<=0;
            tophit<=0;
            midhit<=0;
        end        
///////////////////////////////////////////////////        


        if(en) begin
        
            if(pad>=(512-HEIGHT)) begin
                currentY<=512-HEIGHT;
            end
            
            if(pad<= 136) begin
                currentY<= 136;
            end
            if(pad >=136 && pad<=(512-HEIGHT))begin
                currentY<=pad;
            end
        end
        
   /*     if(en && pad && (currentY < BOTTOM_BOUND)) begin
            currentY<=currentY+YSPEED;
        end
  */  end
    
   





end



endmodule
