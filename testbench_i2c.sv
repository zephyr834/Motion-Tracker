/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*File: testbench_i2c
*Created by: Cory Eighan
*Date: 13 July 2012
*Revised: 
9/5/12-Changed from Active high to active low.
*Notes:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

module testbench_i2c(
iClock,
iReset,
LED5,
LED6,
iTransmit,
iSCL,
ioSDA
);

input		    	iClock;
input		    	iReset;
output              LED5;
output              LED6;
input               iTransmit;
input               iSCL;
inout               ioSDA;

//===================================
//			Parameters
//===================================

parameter IDLE				= 4'h0;
parameter START			    = 4'h1;
parameter SEND_ADDR		    = 4'h2;
parameter ACK_ADDR		    = 4'h3;
parameter SEND_DATA		    = 4'h4;
parameter ACK_DATA		    = 4'h5;
parameter SEND_DATA1	    = 4'h6;
parameter ACK_DATA1		    = 4'h7;
parameter HOLD				= 4'h8;
parameter STOP				= 4'h9;
parameter WAIT              = 4'hA;
parameter WAIT2             = 4'hB;

parameter HIGH              = 1'b1;
parameter LOW               = 1'b0;   
//====================================
//			REG/WIRE Declarations
//====================================
reg             sda_oe;
reg             sda_in;
reg     [3:0]   I2C_State;
reg     [3:0]   Counter;
reg     [7:0]   data;
reg     [3:0]   bit_count;
reg             old_scl;

wire ioSDA = (sda_oe) ? 1'bz: 1'b0;

//===================================
//			Port Declarations
//===================================

//====================================
//			Structural Coding
//====================================

always@(posedge iClock or negedge iReset)
begin
    if (iReset == 1'b0)
    begin
        I2C_State       <=  IDLE;
        LED5            <=  1'b0;
        LED6            <=  1'b0;
    end
    
    else
    begin
        case(I2C_State)
            IDLE: begin
                sda_oe      <=  HIGH;
                sda_in      <=  ioSDA;
                if (iTransmit == 1'b1 && iSCL == 1'b1)
                begin
                    I2C_State           <=  START;
                    bit_count           <=  4'h7;
                end
            end
            START: begin
                case(Counter)
                    0:begin
                        sda_oe      <=  HIGH;
                        sda_in      <=  ioSDA;
                        
                        if (sda_in == 1'b1 && iSCL == 1'b1)
                            Counter         <=  Counter + 1'b1;
                    end
                    
                    1:begin
                        sda_oe      <=  HIGH;
                        sda_in      <=  ioSDA;
                        if (sda_in == 1'b0 && iSCL == 1'b1)
                            Counter         <=  Counter + 1'b1;
                    end
                    
                    2:begin
                        sda_oe      <=  HIGH;
                        sda_in      <=  ioSDA;
                        if (sda_in == 1'b0 && iSCL == 1'b0)
                        begin                           
                            old_scl         <=  1'b0;
                            I2C_State       <=  SEND_ADDR;
                            Counter         <=  4'h0;
                        end
                    end
                endcase
            end
            SEND_ADDR:begin
                sda_oe      <=  HIGH;
                sda_in      <=  ioSDA;
                
                if (iSCL == 1'b1 && old_scl == 1'b0)    //opposite of I2C Master; waits till ioSDA is stable
                begin
                    old_scl             <=  1'b1;
                    data[bit_count]     <=  sda_in;
                    if (bit_count == 4'h0)
                    begin
                        bit_count       <=  4'h7;
                        I2C_State       <=  ACK_ADDR;
                    end
                end
                else if (iSCL == 1'b0 && old_scl == 1'b1)
                begin
                    old_scl         <=  1'b0;
                    bit_count       <=  (bit_count - 1'b1);
                end
            end
            ACK_ADDR:begin
                if (iSCL == 1'b0)
                begin
                    old_scl         <= 1'b0;
                    if (data == 8'h42)
                    begin
                        sda_oe          <=  LOW;
                    end
                    else
                        sda_oe          <=  HIGH;
                end
                else if (old_scl == 1'b0 && iSCL == 1'b1)
                begin
                    old_scl         <=  1'b1;   //changed value to avoid step
                    I2C_State       <=  WAIT;
                end
            end
            WAIT:begin
                if(old_scl == 1'b1 && iSCL == 1'b0)
                begin
                    I2C_State       <=  SEND_DATA;
                    old_scl         <=  1'b0;                  
                end
            end
            SEND_DATA:begin
                sda_oe          <=  HIGH;
                sda_in          <=  ioSDA;
                
                if (iSCL == 1'b1 && old_scl == 1'b0)
                begin
                    old_scl             <=  1'b1;
                    data[bit_count]     <=  sda_in;
                    
                    if (bit_count == 4'h0)
                    begin                        
                        bit_count       <=  4'h7;
                        I2C_State       <=  ACK_DATA;
                    end
                end
                else if (iSCL == 1'b0 && old_scl == 1'b1)
                begin
                    old_scl         <=  1'b0;
                    bit_count       <=  (bit_count - 1'b1);
                end
            end
            ACK_DATA:begin
                if (iSCL == 1'b0)
                begin
                    old_scl         <= 1'b0;
                    if (data == 8'h12)
                    begin
                        LED5            <=  1'b1;
                        sda_oe          <=  LOW;
                    end
                    else
                        sda_oe          <=  HIGH;
                end
                else if (old_scl == 1'b0 && iSCL == 1'b1)
                begin
                    old_scl         <=  1'b1;
                    I2C_State       <=  WAIT2;
                end
            end
            WAIT2:begin
                if(old_scl == 1'b1 && iSCL == 1'b0)
                begin
                    I2C_State       <=  SEND_DATA1;
                    old_scl         <=  1'b0;                  
                end
            end
            SEND_DATA1:begin
                sda_oe      <=  HIGH;
                sda_in      <=  ioSDA;
                
                if (iSCL == 1'b1 && old_scl == 1'b0)
                begin
                    old_scl             <=  1'b1;
                    data[bit_count]     <=  sda_in;
                    if (bit_count == 3'h0)
                    begin
                        bit_count       <=  3'h7;
                        I2C_State       <=  ACK_DATA1;
                    end
                end
                else if (iSCL == 1'b0 && old_scl == 1'b1)
                begin
                    old_scl         <=  1'b0;
                    bit_count       <=  (bit_count - 1'b1);
                end
            end
            ACK_DATA1:begin
                if (iSCL == 1'b0)
                begin
                    old_scl         <= 1'b0;
                    if (data == 8'h80)
                    begin
                        LED6            <=  1'b1;
                        sda_oe          <=  LOW;
                    end
                    else
                        sda_oe          <=  HIGH;
                end
                else if (old_scl == 1'b0 && iSCL == 1'b1)
                begin
                    old_scl         <=  1'b0; //changed value to avoid step
                    I2C_State       <=  STOP;
                end
            end
            STOP:begin
                I2C_State       <=  STOP;
            end
        endcase
    end
end

endmodule 