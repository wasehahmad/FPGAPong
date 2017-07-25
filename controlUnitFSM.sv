`timescale 1ns / 1ps



module controlUnitFSM(
input logic clk,
input logic reset,
input logic serve,
input logic miss_l,
input logic miss_r,
output logic srv_r,
output logic srv_l,
output logic visible,
output logic [3:0]rightScore,
output logic [3:0]leftScore
    );

typedef enum logic [2:0] {S0,S1,S2,S3,S4,S5,S6,S7} state_type;
 
state_type[2:0] state, next;  


logic firstServed;
logic rScored; logic lScored;



always_ff @(posedge clk)begin
    if(reset)begin
        state <= S0;
        leftScore<=0;
        rightScore<=0;
        firstServed<=0;

        
    end
    else begin
        state <=next;   
    end
    
    if(rScored)begin
        rightScore<=rightScore+1;
    end
    if(lScored)begin
        leftScore<=leftScore+1;
    end
end
    
always_comb begin
    srv_r=0;
    srv_l=0;
    next=S0;
    rScored=0;
    lScored=0;
    visible=1;
    
    case(state)
        S0: begin
                
                srv_l=0;
                srv_r=0; 
                if(leftScore==0 && rightScore ==0 && !miss_r && !miss_l)begin 
                    next=S5;
                end  
                if(miss_r) begin 
                    next=S1; 
                    lScored=1;
                    if(leftScore==10) begin //if the score was 10 and the game point was just won
                        next=S7;
                    end 
                end
                if(miss_l) begin   
                    next=S3; 
                    rScored=1;
                    if(rightScore==10) begin
                        next=S7;
                    end 
                end
                if(!miss_l && !miss_r && !(leftScore==0 && rightScore==0)) begin
                    next=S0;
                end
                
                
            end
            
        S1:
            begin
                if(serve) begin 
                    next=S2;
                    srv_r=1; 
                end
                else begin
                    next=S1;
                end
            end
            
        S2:
            begin
                if(!miss_r)begin
                    next=S0;
                end
                else begin
                    srv_r=1;
                    next=S2;
                end
            end
            
        S3:
            begin
                if(serve) begin  
                    next=S4;
                    srv_l=1; 
                end
                else begin
                    next=S3;
                end
            end
            
        S4:
            begin
                if(!miss_l) begin  
                    next=S0;
                end
                else begin
                    srv_l=1;  
                    next=S4;
                end
            end   
            
        S5:
            begin
                visible=1;       
                if(serve) begin        //if the serve button is pushed
                    srv_l=1;
                    next=S6; 
                end 
                else begin    
                    next=S5; 
                end
            end
            
        S6:
            begin
                
                if(!firstServed)begin
                    srv_l=1;
                    firstServed=1;
                end
                else begin
                    srv_l=0;
                end
                if(miss_l||miss_r)begin     
                    next=S0;
                    srv_l=0; 
                end
                else begin      
                    next= S6; 
                end
            end
         
        S7:
            begin
                next=S7;
                srv_l=0;
                srv_r=0;
                visible=0;
            
            end
    
    endcase




end    
    
endmodule
