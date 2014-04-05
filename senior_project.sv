/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Project: Video Processing and Blob Detection
Description:
DE0-Nano Dev board with Cyclone IV utilizing an
OV7670 camera module through I2C. FPGA will process
frames and calculate blobs in front of camera.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

module senior_project(

input 		  			CLOCK_50,
input		[3:0]		DIP_SWITCH,
input					iVsync,
input					iHref,
input					iPclk,
input		[7:0]		iPdata,
inout					ioSDA,
output                  oAck,
output                  oNack,
output					oSCL,
output					oClock_24,
output					oPower_2v5,
output					oReset,
output                  oXpwm,
output                  oYpwm,
output      [7:0]		oYdata,
output	    [7:0]		LED

);

//===================================
//			Parameters
//===================================


//===================================
//  REG/WIRE declarations
//===================================
wire	  [7:0]     data_in;
wire	  [7:0]     data_out;
wire	  [6:0]     slv_addr;
wire                enlatch;

wire				clock_24;
wire				clock_48;
wire				href;
wire				vsync;
wire				pclk;
wire      [7:0]     Xmin;
wire      [7:0]     Xmax;
wire      [7:0]     Ymin;
wire      [7:0]     Ymax;
wire      [7:0]     Xmin_dum;
wire      [7:0]     Xmax_dum;
wire      [7:0]     Ymin_dum;
wire      [7:0]     Ymax_dum;
wire      [7:0]     Xduty;
wire      [7:0]     Yduty;
wire                Newcoord;
wire                reset;
wire                sda;
wire                scl;
wire                Xpwm;
wire                Ypwm;
wire                read_en;
wire                write_en;
wire                fifo_empty;
wire    [3:0]       mem_datain;
wire    [3:0]       mem_dataout;
wire                new_coord;
wire    [14:0]      mem_address;

wire    [7:0]       led_frame;
wire    [7:0]       led_yuv;
wire    [7:0]       led_i2c;
wire    [7:0]       led_pixel;
wire    [7:0]       led_blob;
wire    [7:0]       led_pwm;
wire    [7:0]		y_data;
wire    [7:0]		u_data;
wire    [7:0]		v_data;
wire    			rdy;
wire    			ack;
wire    			nack;
wire    			transmit;
wire    			receive;
wire    			hold;
wire                new_frame;
wire                ready_flag;
wire                enlatch_dum;
wire    [7:0]		y_data_dum;

//assign              LED[6:0]         = led_yuv[6:0];
//assign              LED[7]         = led_i2c[7];
assign              LED         = led_frame;
assign              oAck        = ack;
assign              oNack       = nack;         
assign              oYdata      = mem_dataout;
assign 			    oPower_2v5  = 1'b1;
assign              oReset      = reset;
//===================================
//			Port Declarations
//===================================

I2C_MASTER	u_i2c_master (
			.iClk(clock_24),
			.iReset(reset),
			.iSlv_Addr(slv_addr),
			.iData(data_in),
			.oData(data_out),
			.iTransmit(transmit),
			.iReceive(receive),
			.iHold(hold),
			.oSCL(oSCL),
			.ioSDA(ioSDA),
            .oLED(led_i2c),
			.oReady(rdy),
			.oAck(ack),
			.oNack(nack));
			
pll_24_96	u_pll_24_96 (
			.inclk0(CLOCK_50),
			.c0(clock_24),
			.c1(clock_48),
            .c2(oClock_24));

Reset_Generator u_reset_generator(
			.iClk(clock_48),
			.iReset_Switch(DIP_SWITCH[0]),
			.oReset_En(reset));
			
yuv_camera u_yuv_camera(
			.iClock(clock_48),
			.I2C_Clock(clock_24),
            .oSlv_Addr(slv_addr),
            .oI2C_Data(data_in),
            .oTransmit(transmit),
            .iI2C_Ready(rdy),
            .iAck(ack),
            .iNack(nack),  
			.iReset(reset),
			.iHref(iHref),
			.iVsync(iVsync),
			.iPdata(iPdata),
			.iPclk(iPclk),
            .LED(led_yuv),
            .oReadyFlag(ready_flag),
            .oEnLatch(enlatch));

blob_center u_blob_center(
            .iClock(clock_48),
            .iReset(reset),
            .iXmin(Xmin),
            .iXmax(Xmax),
            .iYmin(Ymin),
            .iYmax(Ymax), 
            .iNewCoord(new_coord),
            .oLED(led_blob),
            .oXduty(Xduty),
            .oYduty(Yduty));
            
pwm_creator u_pwm_creator(
            .iClock(clock_48),
            .iReset(reset),
            .iXduty(Xduty),
            .iYduty(Yduty),
            .oLED(led_pwm),
            .oXpwm(oXpwm),
            .oYpwm(oYpwm));

frame_array u_frame_array(
            .iClock(clock_48),
            .iReset(reset),
            .iYdata(iPdata),
            .iEnLatch(enlatch),
            .iMemData(mem_dataout),
            .iHref(iHref),
            .iNewFrame(new_frame),
            .iReadyFlag(ready_flag),
            .oReadEn(read_en),
            .oMemAddr(mem_address),
            .oNewCoord(new_coord),
            .oLED(led_frame),
            .oWriteEn(write_en),
            .oMemData(mem_datain),
            .oXmin(Xmin),
            .oXmax(Xmax),
            .oYmin(Ymin),
            .oYmax(Ymax));
       
pixel_counter   u_pixel_counter(
                .iClock(clock_48),
                .iReset(reset),
                .iVsync(iVsync),
                .iHref(iHref),
                .iReadyFlag(ready_flag),
                .iPclk(iPclk),
                .iPdata(iPdata),
                .oNewFrame(new_frame),
                .oLED(led_pixel));
                
memory          u_memory (
                .address(mem_address),
                .clock(clock_48),
                .data(mem_datain),
                .rden(read_en),
                .wren(write_en),
                .q(mem_dataout));                          
                
/*
testbench_framearray u_testbench_framearray(
            .iClock(clock_24),
            .iReset(reset),
            .oEnLatch(enlatch_dum),
            .oYdata(y_data_dum));
            

testbench_i2c  u_testbench_i2c(
            .iClock(clock_24),
            .iReset(reset),
            .LED5(LED[5]),
            .LED6(LED[6]),
            .iTransmit(transmit),
            .iSCL(scl),
            .ioSDA(sda));
          
*/           
 
testbench_blobcenter u_testbench(
            .iClock(clock_48),
            .iReset(reset),
            .oXmin(Xmin_dum),
            .oXmax(Xmax_dum),
            .oYmin(Ymin_dum),
            .oYmax(Ymax_dum));

  
//===================================
//			Structural Coding
//===================================


endmodule
