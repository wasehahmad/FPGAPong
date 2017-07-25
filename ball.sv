`timescale 1ns / 1ps


module ball(
input logic clk,
input logic reset,
input logic en,
input logic [9:0]x,
input logic [9:0] y,
input logic visible,
input logic srv_l,
input logic srv_r,
input logic tophit_l,
input logic midhit_l,
input logic bothit_l,
input logic tophit_r,
input logic midhit_r,
input logic bothit_r,
output logic [11:0]rgb,
output logic miss_l,
output logic miss_r,
output logic [9:0] ball_x,
output logic [2:0] yS,
output logic [9:0] ball_y
 );
 
parameter YLOC = 324;
parameter XLOC = 394;
parameter WIDTH = 10;
parameter HEIGHT =10;
parameter COLOR = 12'hfff;
parameter V_X = 2;  
parameter TOP_BOUND = 136;
parameter BOTTOM_BOUND = 512-HEIGHT;
     
 logic [9:0]currentX; 
 logic [9:0]currentY;
 logic [2:0]xSpeed; //changed this
 logic [2:0]ySpeed; //changed this
 logic [2:0]counter;
 logic served;
 logic ySwitched;
 logic xSwitched;
 logic passedNet;
         
 assign ball_x = currentX;
 assign ball_y = currentY;    
 
 assign yS=ySpeed;    
     
 always_comb begin
     if((x>= currentX) && (x<= currentX+WIDTH) && (y>=currentY) && (y<= currentY + HEIGHT) && visible)begin
         rgb = COLOR;
     end  
     else begin
         rgb = 0;
     end
     

 end
 
 always_ff@(posedge clk)
 begin
    if(reset)begin//sets the starting place of the ball
        currentX<=XLOC;
        currentY<=YLOC;
        miss_l<=0;
        miss_r<=0;
        xSwitched<=0;
        ySwitched<=0;
        served<=0;  //temp changed this from 0
        xSpeed<=0; //temp changed this from 0
        ySpeed<=0;      //temp changed this from 0
        
    end
    
    else begin
        if(en) begin
            if(counter>=5)begin//the counter cycles from -5 to 5
                 counter <=0;
            end    
            else begin
                 counter <= counter +1;  
            end
        end
        
        if(en && !served && srv_l && !srv_r)begin //if the left person has served
            served<= 1;         
            ySpeed<=counter;    
            xSpeed<=V_X;
            miss_l=0;      //these are done here so that immediately after the ball has been served, the input to the finite state machine should be miss_l and miss_r =0
            miss_r=0;
            xSwitched=0;
            
        end
        else if(en  && !served && srv_r && !srv_l)begin //if the right player has served
            served<= 1;
            ySpeed<=counter;
            xSpeed<=V_X;
            xSwitched=1;
            miss_l=0;
            miss_r=0;
        end
        
        
        
  //      if begin  
            if(currentX<=0 )begin //5 is just a value behind the paddle
                miss_l=1;
                currentX=XLOC;
                currentY=YLOC;
                served=0;
            end
            if(currentX>=799) begin
                miss_r=1;
                currentX=XLOC;
                currentY=YLOC;
                served=0;
            end
  //      end    
       
        //if the ball has been served and the ball is in the region
        if(en && served && (currentY>TOP_BOUND && currentY<=BOTTOM_BOUND && currentX<799 && currentX>0))begin

            
            if(xSwitched)begin//use x and y switched as - sign doesnt appear to work . for a value.
                currentX <= currentX-V_X;
            end    
            else begin
                currentX<= currentX+V_X;
            end
            
            if(ySwitched)begin
                currentY <= currentY-ySpeed;
            end
            else begin    
                currentY <= currentY+ySpeed;
            end
        end
        
        //if the ball hits the top or bottom wall, reverse y speed
        else if(en && served && (currentY <= TOP_BOUND || currentY >= BOTTOM_BOUND))begin
            if(ySwitched)begin
                ySwitched<=0;
                currentY<=currentY+ySpeed; // need to add this to make sure ball gets up from the boundary and out of the bounds back into the condition to be able to move
            end    
            else begin
                ySwitched<=1;
                currentY<=currentY-ySpeed;    
            end    
        end
        //conditions for when the ball module outputs a miss
        
        if(currentX>=396 && currentX<=404) begin
            passedNet<=1;
        end

       
        if(passedNet)begin  //as the ball stays on the paddle for more than one cycle, until it passes the net, it can    
 ///////////////////////////////////////////////////        
        if(tophit_r)begin
            xSwitched=1;
            if(ySpeed>0)begin
                ySpeed<=ySpeed-1;
            end
            passedNet=0;
        end
        if(midhit_r)begin
            xSwitched=1;
            passedNet=0;
        end
        if(bothit_r)begin
            xSwitched=1;
            if(ySpeed<5)begin
                ySpeed<=ySpeed+1;
            end
            passedNet=0;
        end
 ////////////////////////////////////////////////////////////       
        if(tophit_l)begin
            xSwitched=0;
            if(ySpeed>0)begin
                ySpeed<=ySpeed-1;
            end
            passedNet=0;
        end
        if(midhit_l)begin
            xSwitched=0;
            passedNet=0;
        end
        if(bothit_l)begin
            xSwitched=0;
            if(ySpeed<5)begin
                ySpeed<=ySpeed+1;
            end
            passedNet=0;
        end        
////////////////////////////////////////////////////////          
          
     end
        
     
     end
 
    
 
 end
 
 
endmodule
