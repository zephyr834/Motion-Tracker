/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*File: yuv Camera
*Created by: Cory Eighan
*Date: 13 July 2012
*Revised: None
*Credit: Jonathan Piat
*Description: Sets up the register files of the camera and takes
in the pixel data.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

module yuv_camera (
iClock,
I2C_Clock,
oSlv_Addr,
oI2C_Data,
oTransmit,
iI2C_Ready,
iAck,
iNack,
iReset,
iHref,
iVsync,
iPdata,
iPclk,
LED,
oReadyFlag,
oEnLatch

);

input					iClock;
input					I2C_Clock;
input                   iI2C_Ready;
input                   iAck;
input                   iNack;
input					iReset;
input					iHref;
input					iVsync;
input		[7:0]		iPdata;
input					iPclk;
output                  oReadyFlag = delay_flag;
output      [6:0]       oSlv_Addr;
output      [7:0]       oI2C_Data;
output                  oTransmit;
output      [7:0]       LED;
output                  oEnLatch;


//====================================
//				Parameters
//====================================	
	
parameter	CAMERA_ADDR =   7'b0100001;
parameter   RESET       =   4'h0;
parameter	START_ROM	=	4'h1;
parameter	REGADDR	    =	4'h2;
parameter	ACK_STATE1	=	4'h3;
parameter	REGDATA	    =	4'h4;
parameter	ACK_STATE2	=	4'h5;
parameter	NEXT_REG	=	4'h6;
parameter	STOP_ROM	=	4'h7;

parameter   DELAY       =   4'h0;
parameter	LINE_START	=	4'h1;
parameter	Y1_DATA		=	4'h2;
parameter	U_DATA		=	4'h3;
parameter	Y2_DATA		=	4'h4;
parameter	V_DATA		=	4'h5;

parameter   RESET_DELAY  =   28'h16E3600;

//====================================
//			REG/WIRE Declarations
//====================================
reg                 count;
reg                 delay_flag;
wire    [7:0]       i2c_data_in;
reg 	[15:0]	    reg_data;
reg		[7:0]		reg_addr;
wire	[6:0]		slave_addr;
reg     [27:0]      delay_counter;
reg     [27:0]      delay_counter2;
wire                transmit;

reg		[3:0]		reg_state;
reg		[3:0]		frame_state;
wire                pclk_old;
wire				en_ylatch;
wire				en_ulatch;
wire				en_vlatch;

assign              oEnLatch  = en_ylatch;
assign              oSlv_Addr = slave_addr;
assign              oI2C_Data = i2c_data_in;
assign              oTransmit = transmit;

reg     [11:0]      row_counter;
reg     [3:0]       test_counter;

//====================================
//			Port Declarations
//====================================
			
			

camera_rom u_camera_rom(
			.iClock(iClock),
			.iEn(1'b1),
			.iAddr(reg_addr),
			.oData(reg_data));

//====================================
//			Structural Coding
//====================================

//Set-up for Camera Rom
always@(posedge I2C_Clock or negedge iReset)
begin
	if (iReset == 1'b0)
	begin
		reg_state		<=	RESET;
		reg_addr		<=	8'h00;
    //    LED             <=  8'hFF;
        delay_flag      <=  1'b0;
        test_counter    <=  4'h0;
	end
	else
	begin
        slave_addr		<=	CAMERA_ADDR;
		case (reg_state)
            RESET:begin
                if (delay_counter == RESET_DELAY)
                begin
                    delay_counter   <=  28'h0000000;
                    reg_state       <=  START_ROM;
     //               LED             <=  8'h00;
                end
                else
                begin
                    delay_counter   <=  delay_counter + 1'b1;
      //              LED             <=  reg_data[15:8];
                end
            end
			START_ROM: begin
				if (iI2C_Ready == 1'b1)		//I2C bus is ready
				begin                    
					transmit		<= 1'b1;
					i2c_data_in		<= reg_data[15:8];		//register address                    
					reg_state		<= REGADDR;
				end
			end
			REGADDR: begin
    //            LED     <=  8'h80;
				if (iAck == 1'b1)				//waits for ack to be pulled high
				begin                    
					transmit		<= 1'b1;	
                    i2c_data_in		<= reg_data[7:0];		//register data
					reg_state		<= ACK_STATE1;
				end
			end
			ACK_STATE1: begin
     //           LED     <=  8'h40;
				if (iNack == 1'b1)				//transmit failed
				begin
					transmit		<= 1'b0;
					reg_state		<= NEXT_REG;
 //                   test_counter    <=  test_counter + 1'b1;///////////TODO
				end
				else if (iAck == 1'b0)		//slave acknowledged data
				begin                                 
					reg_state		<= REGDATA;
                    test_counter    <=  test_counter + 1'b1; ///////////TODO
				end
			end
			REGDATA: begin
     //           LED     <=  8'h20;
				if (iAck == 1'b1)	
				begin
					transmit			<= 1'b0;
					reg_state			<= ACK_STATE2;
                    reg_addr            <= reg_addr + 1'b1;
				end
			end
			ACK_STATE2: begin
     //           LED     <=  8'h10;
				if (iNack == 1'b1 || iAck == 1'b0)
				begin                             
					reg_state		<=	NEXT_REG;
					transmit		<=	1'b0;
				end
			end
			NEXT_REG: begin
				transmit        <=  1'b0;
				if ( (reg_addr >= 8'h06) || (reg_data[15:8]	==	8'hFF))
				begin
					reg_state		<= STOP_ROM;
					transmit		<=	1'b0;
				end
				
				else if (iI2C_Ready == 1'b1 && iAck == 1'b0)
				begin
					reg_state		<=	RESET;
               //     i2c_data_in		<=  reg_data[15:8];		//register data
				//	transmit		<=	1'b1;
				end
			end
			STOP_ROM: begin
                delay_flag          <=  1'b1;
    //            LED                 <=  {4'b1000,test_counter};///////////TODO
				transmit			<=  1'b0;
			end      
		endcase
	end
end

//NOTE: iPclk is 24Mhz; iClock is 48Mhz
always@(posedge iClock or negedge iReset)
begin
    if (iReset == 1'b0)
    begin
        frame_state			<=	DELAY;
        en_ylatch			<=	1'b0;
        en_ulatch			<=	1'b0;
        en_vlatch			<=	1'b0;
        LED                 <=  8'h00;
    end
    else
    begin
        case (frame_state)
                DELAY:begin
                    if(delay_flag == 1'b1)
                        frame_state     <=  LINE_START;
                end
                LINE_START: begin                   
                    if ( (iHref == 1'b1) && (iVsync	==	1'b0) )
                    begin
                        frame_state			<=	Y1_DATA;                       
                        row_counter         <=  12'h000;
                    end
                end
                Y1_DATA: begin
                    en_ylatch			<=	iPclk;
                    if (iHref == 1'b0 || iVsync == 1'b1)
                    begin
                        frame_state         <=  LINE_START;
                        LED                 <=  row_counter[7:0];
                    end
                    else if (iPclk == 1'b0 && pclk_old == 1'b1)
                    begin
                        frame_state			<=	U_DATA;
                        row_counter         <=  row_counter + 1'b1;
                    end
                end
                U_DATA: begin
                    en_ulatch			<=	iPclk;
                    if (iHref == 1'b0 || iVsync == 1'b1)
                    begin
                        frame_state         <=  LINE_START;
                        LED                 <=  row_counter[7:0];
                    end
                    else if (iPclk == 1'b0 && pclk_old == 1'b1)
                    begin
                        frame_state			<=	Y2_DATA;
                    end
                end
                Y2_DATA: begin
                    en_ylatch			<=	iPclk;
                    if (iHref == 1'b0 || iVsync == 1'b1)
                    begin
                        frame_state         <=  LINE_START;
                        LED                 <=  row_counter[7:0];
                    end
                    else if (iPclk == 1'b0 && pclk_old == 1'b1)
                    begin
                        frame_state			<=	V_DATA;
                        row_counter         <=  row_counter + 1'b1;
                    end
                end
                V_DATA: begin
                    en_vlatch			<=	iPclk;
                    if (iHref == 1'b0 || iVsync == 1'b1)
                    begin
                        frame_state         <=  LINE_START;
                        LED                 <=  row_counter[7:0];
                    end
                    else if (iPclk == 1'b0 && pclk_old == 1'b1)
                    begin
                        frame_state			<=	Y1_DATA;
                    end
                end
        endcase
    end
end
//stores iPclk to be used for next clock cycle
always@(posedge iClock)
begin
    pclk_old        <=  iPclk;
end
endmodule 