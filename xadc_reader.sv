////////////////////////////////////////////////////////////////////////////
// xadc_reader.sv
//	Provides a way of reading paddle inputs from the XADC interface.
////////////////////////////////////////////////////////////////////////////
module xadc_reader(input logic clk,
		   input logic reset,
		   input logic [7:0] JXADC,
		   output logic [15:0] adc0,
		   output logic [15:0] adc1,
		   output logic [15:0] adc2,
		   output logic [15:0] adc3);   

   logic [6:0] addr;
   logic en;
   logic [15:0] din;
   logic wen;
   logic [15:0] aux_channel_n;
   logic [15:0] aux_channel_p;
   logic [7:0] alm_int;
   logic busy;
   logic [4:0] ch_out;
   logic [15:0] dout;
   logic ready;
   logic eoc;
   logic eos;
   logic gnd_bit;
   logic ot;
   logic [7:0] timeout_reg, timeout_next;
   
   // State machine to continuously read the two 12-bit channels.
   typedef enum [1:0] 	       {LATCH, READ, STORE} state_type;
   state_type state_reg, state_next;

   // Which ADC is being read, and Stored ADC values
   logic [1:0]		       adc_index_reg, adc_index_next;
   logic [15:0] 	       adc_reg, adc_next;
   logic [15:0] 	       adc0_reg, adc0_next;
   logic [15:0] 	       adc1_reg, adc1_next;
   logic [15:0] 	       adc2_reg, adc2_next;
   logic [15:0] 	       adc3_reg, adc3_next;

   parameter AUX_STATUS_BASE = 7'h10;
   parameter TIMEOUT_START = 8'b11111111;
   
   assign gnd_bit = 1'b0;
   
XADC #(
       // Initializing the XADC Control Registers
       //.INIT_40(16'h1000),// Average 16 samples
       .INIT_40(16'h1100),// Average 256 samples       
       .INIT_41(16'h2ff0),// Continuous Sequencer Mode, Disable unused ALMs, Enable calibration
       .INIT_42(16'h0400),// Set DCLK divider to 4, ADC = 500Ksps, DCLK = 50MHz
       .INIT_48(16'h0000),// Sequencer channel - Disable
       .INIT_49(16'h0c0c),// Sequencer channel - enable aux analog channels 0 - 3
       .INIT_4A(16'h0000),// No averaging for temp sensors
       .INIT_4B(16'h0c0c),// Averaging on aux channels
       .INIT_4C(16'h0000),// Sequencer Bipolar selection
       .INIT_4D(16'h0c0c),// Sequencer Bipolar selection
       .INIT_4E(16'h0000),// Sequencer Acq time selection
       .INIT_4F(16'h0000),// Sequencer Acq time selection
       .INIT_50(16'hb5ed),// Temp upper alarm trigger 85°C
       .INIT_51(16'h5999),// Vccint upper alarm limit 1.05V
       .INIT_52(16'hA147),// Vccaux upper alarm limit 1.89V
       .INIT_53(16'hdddd),// OT upper alarm limit 125°C
       .INIT_54(16'ha93a),// Temp lower alarm reset 60°C
       .INIT_55(16'h5111),// Vccint lower alarm limit 0.95V
       .INIT_56(16'h91Eb),// Vccaux lower alarm limit 1.71V
       .INIT_57(16'hae4e),// OT lower alarm reset 70°C
       .INIT_58(16'h5999),// VCCBRAM upper alarm limit 1.05V
       .INIT_5C(16'h5111),// VCCBRAM lower alarm limit 0.95V
       .SIM_MONITOR_FILE("sensor_input.txt")
       // Analog Stimulus file. Analog input values for simulation
       )
U_XADC1 ( // Connect up instance IO. See UG480 for port descriptions
	    .CONVST(gnd_bit), // not used
	    .CONVSTCLK(gnd_bit), // not used
	    .DADDR(addr),
	    .DCLK(clk),
	    .DEN(en),
	    .DI(din),
	    .DWE(wen),
	    .RESET(rst),
	    .VAUXN(aux_channel_n[15:0]),
	    .VAUXP(aux_channel_p[15:0]),
	    .ALM(alm_int),
	    .BUSY(busy),
	    .CHANNEL(ch_out),
	    .DO(dout),
	    .DRDY(ready),
	    .EOC(eoc),
	    .EOS(eos),
	    .JTAGBUSY(),// not used
	    .JTAGLOCKED(),// not used
	    .JTAGMODIFIED(),// not used
	    .OT(ot),
	    .MUXADDR(),// not used
	    .VP(gnd_bit),
	    .VN(gnd_bit)
	  );

   assign aux_channel_p[3] = JXADC[0];
   assign aux_channel_n[3] = JXADC[4];

   assign aux_channel_p[10] = JXADC[1];
   assign aux_channel_n[10] = JXADC[5];
   
   assign aux_channel_p[2] = JXADC[2];
   assign aux_channel_n[2] = JXADC[6];
   
   assign aux_channel_p[11] = JXADC[3];
   assign aux_channel_n[11] = JXADC[7];
   
   always_ff @(posedge clk)
     begin
	if (rst)
	  begin
	     adc_index_reg <= 0;
	     adc_reg <= 0;
	     adc0_reg <= 0;
	     adc1_reg <= 0;
	     adc2_reg <= 0;
	     adc3_reg <= 0;
	     timeout_reg <= 0;
	     state_reg <= LATCH;
	  end
	else
	  begin
	     adc_index_reg <= adc_index_next;
	     adc_reg <= adc_next;
	     adc0_reg <= adc0_next;
	     adc1_reg <= adc1_next;
	     adc2_reg <= adc2_next;
	     adc3_reg <= adc3_next;
	     timeout_reg <= timeout_next;
	     state_reg <= state_next;
	  end // else: !if(rst)
     end // always_ff @ (posedge clk)

   // Lookup address of ADC data from index.  We scan from right to left
   // on the PMOD connector.
   always_comb
     case(adc_index_reg)
       2'd0: addr = AUX_STATUS_BASE + 3;
       2'd1: addr = AUX_STATUS_BASE + 10;
       2'd2: addr = AUX_STATUS_BASE + 2;
       2'd3: addr = AUX_STATUS_BASE + 11;
       default: addr = 0;
     endcase // case (adc_index_reg)
   
   always_comb
     begin
	// Defaults
	state_next = LATCH;
	adc_next = adc_reg;
	adc0_next = adc0_reg;
	adc1_next = adc1_reg;
	adc2_next = adc2_reg;
	adc3_next = adc3_reg;
	adc_index_next = adc_index_reg;
	timeout_next = timeout_reg;
	en = 0;
	wen = 0;
	// Next-state
	case (state_reg)
	  LATCH:
	    // Latch the address for the read operation
	    begin
	       en = 1;
	       timeout_next = TIMEOUT_START;
	       state_next = READ;
	    end
	  READ: 
	    // Wait for valid data to be present, which will be latched
	    begin
	       timeout_next = timeout_reg - 1;
	       if (ready) begin
		 adc_next = dout;
		 state_next = STORE;
	       end
	       else if (timeout_reg == 0)
		 state_next = LATCH;
	       else
		 state_next = READ;
	    end
	  STORE:
	    // Now store the latched value in the appropriate register
	    begin
	       case (adc_index_reg)
		 2'd0: adc0_next = adc_reg;
		 2'd1: adc1_next = adc_reg;
		 2'd2: adc2_next = adc_reg;
		 2'd3: adc3_next = adc_reg;
	       endcase // case (adc_index_reg)
	       adc_index_next = adc_index_reg + 1;
	       state_next = LATCH;
	    end
	endcase // case (state_reg)
     end // always_comb begin

   // Connect outputs
   assign adc0 = adc0_reg;
   assign adc1 = adc1_reg;
   assign adc2 = adc2_reg;
   assign adc3 = adc3_reg;
   
endmodule
   
