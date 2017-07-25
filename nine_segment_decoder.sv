`timescale 1ns / 1ps


module nine_segment_decoder(
input logic [3:0] data,
output logic [8:0] segments

    );
    
    always_comb
    case (data)
    4'd0: segments = 9'b000111111;
    4'd1: segments = 9'b000000110;
    4'd2: segments = 9'b001011011;
    4'd3: segments = 9'b001001111;
    4'd4: segments = 9'b001100110;
    4'd5: segments = 9'b001101101;
    4'd6: segments = 9'b001111101;
    4'd7: segments = 9'b000000111;
    4'd8: segments = 9'b001111111;
    4'd9: segments = 9'b001100111;
    4'd10: segments = 9'b110111111;
    4'd11: segments = 9'b110000110;
    default: segments = 9'b000000000;
    endcase // case(data)

endmodule
