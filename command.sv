`timescale 1ns / 1ps
/////////////////////////////////

//still need to work on finite state machine. paddles closer to wall
//paddle speed increased
//check if hitting different positions of the paddle actuall changes the y speed

module Command(
input logic clk_100mhz,
input logic serve_pb,
input logic reset,
input logic [7:0]  JXADC,
input logic player2_down,
output logic [3:0]vgaRed,
output logic [3:0]vgaBlue,
output logic [3:0]vgaGreen,
output logic Hsync,
output logic Vsync
    );
    
 
       
    logic clk;
    logic frame;
    logic [11:0]color;
    logic [9:0]tempX;
    logic [9:0]tempY;
    logic [11:0] rgb1;logic [11:0] rgb2; logic [11:0] rgb3; logic [11:0] rgb4; logic [11:0] rgb5; logic [11:0] rgb6; 
    logic tophit_l;logic tophit_r;
    logic bothit_l;logic bothit_r; 
    logic midhit_l;logic midhit_r;  
    logic [9:0]BALL_X; logic [9:0]BALL_Y; 
    logic miss_l; logic miss_r;
    logic srv_l; logic srv_r;
    logic visible;
    logic [3:0] rightScore;
    logic [3:0] leftScore;
    logic [8:0] nineSegments_l;
    logic [8:0] nineSegments_r;
    logic [15:0] adc0, adc1;
    logic [9:0]  adc_pad0, adc_pad1;
    
    
    logic [2:0] ySpeed;

    VESADriver vesaDriver(.clk(clk), .Hsyncb(Hsync), .Vsyncb(Vsync), .x(tempX), .y(tempY), .frame(frame) );    
    clkdiv #(.DIVFREQ(50000000)) clkdiv1(.clk(clk_100mhz), .reset(0), .sclk(clk));
    
    nine_segment_decoder LEFT_NINE_DECODER(.data(leftScore), .segments(nineSegments_l));
    nine_segment_decoder RIGHT_NINE_DECODER(.data(rightScore), .segments(nineSegments_r));
    
    score_board#(.XLOC(100),.YLOC(50)) LEFTSCORE(.x(tempX), .y(tempY),.segment(nineSegments_l),.rgb(rgb5));
    score_board#(.XLOC(699), .YLOC(50)) RIGHTSCORE(.x(tempX), .y(tempY),.segment(nineSegments_r),.rgb(rgb6));
    

        
    xadc_reader U_ADC0(.clk(clk), .reset(0), .JXADC(JXADC), .adc0(adc0), .adc1(adc1));

    
    controlUnitFSM CUFSM(.clk(clk), .reset(reset), .serve(serve_pb), .miss_l(miss_l), .miss_r(miss_r), .srv_r(srv_r), .srv_l(srv_l), .visible(visible), .leftScore(leftScore), .rightScore(rightScore));
  
   //player 1 and 2 up and down are substituted by the knob. So modification to be made here. Also, determine the connection to the paddles instead of the down and up for player 1 and 2.  
    paddle #(.XLOC(0), .left(1)) LEFT_PADDLE(.clk(clk), .reset(reset), .en(frame), .x(tempX), .y(tempY), .pad(adc_pad0) , .ball_x(BALL_X), .ball_y(BALL_Y),
                                                               .tophit(tophit_l), .midhit(midhit_l), .bothit(bothit_l), .rgb(rgb1));

    paddle #(.XLOC(789), .right(1)) RIGHT_PADDLE(.clk(clk), .reset(reset), .en(frame), .x(tempX), .y(tempY), .pad(adc_pad1), .ball_x(BALL_X), .ball_y(BALL_Y),
                                                                  .tophit(tophit_r), .midhit(midhit_r), .bothit(bothit_r), .rgb(rgb2));
    
    ball BALL(.clk(clk), .reset(reset), .en(frame), .x(tempX), .y(tempY), .visible(visible), .srv_l(srv_l), .srv_r(srv_r), .tophit_l(tophit_l),.midhit_l(midhit_l), .bothit_l(bothit_l),
              .tophit_r(tophit_r),.midhit_r(midhit_r), .bothit_r(bothit_r),.rgb(rgb4), .miss_l(miss_l), .miss_r(miss_r), .ball_x(BALL_X), .ball_y(BALL_Y) , .yS(ySpeed));
        
    Background BACKGROUND(.x(tempX),.y(tempY), .rgb(rgb3));
    
    assign color = rgb1|rgb2|rgb4|rgb3|rgb5|rgb6;
    
    assign {vgaRed, vgaGreen, vgaBlue} = color;
    
    //need to get the knob connected to test what levels I want to go. This is to determine how far we need to ramp the voltage for the purposes of the game. 
    assign adc_pad0 = adc0[15] ? 10'b0 : (adc0 >> 5);
    assign adc_pad1 = adc1[15] ? 10'b0 : (adc1 >> 5);

endmodule
