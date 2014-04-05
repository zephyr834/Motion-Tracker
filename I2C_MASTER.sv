/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*File: I2C_Master
*Created by: Cory Eighan
*Date: 13 July 2012
*Revised: 2 October 2012
*Credit: Jonathan Piat
*Notes:
I2C is two wire serial bus data transfer. This is the Software Protocol.
Transfers in sequences of 8 bits.
Start Sequence: SCL is High, SDA goes High to Low
Stop Sequence: SCL is High, SDA goes Low to High
Delays are used to help stabalize SDA signals
Receiving Device sends a low ACK bit to signal it received data and is ready again.
Receiving Device sends a High Ack bit(or High Nack bit) to signal it is done and cont. to STOP.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

module I2C_MASTER(
	iClk,
    iReset,
	iSlv_Addr,
	iData,
	oData,
	iTransmit,
	iReceive,
	iHold,
	oSCL,
	ioSDA,
    oLED,
	oReady,
	oAck,
	oNack
);

input 			   	iClk;
input 				iReset;
input	[6:0]		iSlv_Addr;
input	[7:0]		iData;
output	[7:0]		oData;
input				iTransmit;
input				iReceive;
input				iHold;
output				oSCL;
inout				ioSDA;
output    [7:0]     oLED;
output				oReady;
output				oAck;
output				oNack;


//===================================
//			Parameters
//===================================

//I2C States
parameter IDLE				= 4'h0;
parameter START			    = 4'h1;
parameter SEND_ADDR		    = 4'h2;
parameter ACK_ADDR		    = 4'h3;
parameter SEND_DATA		    = 4'h4;
parameter REC_DATA		    = 4'h5;
parameter ACK_DATA		    = 4'h6;
parameter HOLD				= 4'h7;
parameter STOP				= 4'h8;

parameter QUARTER_DELAY     = 8'h3C;    //1E    3C
parameter HALF_DELAY		= 8'h78;
parameter FULL_DELAY		= 8'hF0;

parameter HIGH              = 1'b1;
parameter LOW				= 1'b0;

//====================================
//			REG/WIRE Declarations
//====================================
reg 	[3:0]		I2C_State;
reg	    [7:0]   	tick_count;
reg 	[7:0]		bit_count;
reg 	[7:0]		slave_addr_i;
reg			    	send_rvcb;
reg	    [7:0]   	data_i;

reg                sda_in;
reg                scl_oe;
reg                sda_oe;

//output assignment of inout port
wire ioSDA = (sda_oe) ? 1'bz: 1'b0;
wire oSCL = (scl_oe) ? 1'b1: 1'b0;

//reg      [7:0]      test_counter;
//===================================
//			Port Declarations
//===================================


//====================================
//			Structural Coding
//====================================


always@(posedge iClk or negedge iReset)
begin
	if (iReset == 1'b0) 
	begin
		I2C_State   	<= IDLE;
		scl_oe			<= HIGH;
        sda_oe          <= HIGH;
		tick_count  	<= 8'h00;
		bit_count	    <= 8'h00;
      //  test_counter    <= 8'h01;  //TODO
	end
    
	else
	begin
		case (I2C_State)
			IDLE : begin               
                scl_oe          <= HIGH;
                sda_oe          <= HIGH;
				oReady		    <= 1'b1;
				oAck			<= 1'b0;
				oNack			<= 1'b0;
        //        oLED            <= test_counter;    //TODO                
                
                if (( iTransmit == 1'b1 || iReceive == 1'b1) && (scl_oe == 1'b1) )
                begin               
                    I2C_State		<= START;
                    send_rvcb		<= iTransmit;
                    slave_addr_i  	<= {iSlv_Addr, iReceive};
                    tick_count  	<= 8'h00;
                    bit_count		<= 8'h00;                   
                end
			end
			//Only changed START condition for sda_oe and SDA_out
			START : begin
				oAck			<= 1'b0;
				oNack			<= 1'b0;
				oReady		    <= 1'b0;

				if (tick_count < QUARTER_DELAY) 
				begin
					scl_oe 			<= HIGH;
                    sda_oe          <= HIGH;			
					tick_count      <= (tick_count + 8'h01);
				end
				else if (tick_count < HALF_DELAY) 
				begin
					scl_oe 			<= HIGH;
					sda_oe			<= LOW;
					tick_count      <= (tick_count + 8'h01);
				end 
				else
				begin
					scl_oe 			<= LOW;
					tick_count  	<= 8'h00;
					I2C_State	    <= SEND_ADDR;
				end
			end
			
			SEND_ADDR : begin
				oAck				<= 1'b0;
				oNack				<= 1'b0;
                oReady              <= 1'b0;
				if (bit_count < 4'h8) 
				begin
					if (tick_count < QUARTER_DELAY) 
					begin
						scl_oe 		<=	LOW;
						tick_count	<=	(tick_count + 8'h01); 
					end
					else if (tick_count < HALF_DELAY) 
					begin
						scl_oe			<=	LOW;
                        sda_oe          <=  slave_addr_i[7];
                        sda_in          <=  ioSDA;

						if (sda_in == slave_addr_i[7])
                        begin
							tick_count	<=	(tick_count + 8'h01);
                        end
					end
						
					else if (tick_count < FULL_DELAY)
					begin
						scl_oe 		<= HIGH;
						sda_oe      <= slave_addr_i[7];
                        sda_in      <= ioSDA;
						tick_count	<=	(tick_count + 8'h01);
					end
					else
					begin
						slave_addr_i	<=	{slave_addr_i[6:0], 1'b0};
						bit_count		<=	(bit_count + 8'h01);
						tick_count  	<=  8'h00;
					end
				end
				else
				begin
					bit_count		<=  8'h00;
					scl_oe 			<=	LOW;
					I2C_State		<=	ACK_ADDR;
				end
			end
			
			ACK_ADDR : begin
				oAck			<= 1'b0;
                oReady          <= 1'b0;
				if	(tick_count	<	HALF_DELAY)	
				begin
                    sda_oe      <=  HIGH;
                    sda_in      <=  ioSDA;
					scl_oe 		<=	LOW;
					tick_count	<=	(tick_count + 8'h01);
				end
				else if (tick_count	<	FULL_DELAY) 
				begin
					scl_oe 		<=	HIGH;
					tick_count	<=	(tick_count + 8'h01);
				end
				else
				begin                    
					tick_count  	<= 8'h00;				
					if	(sda_in == 1'b0) 	//Slave drives SDA low if Acknowledge
					begin                 
						oNack			<= 1'b0;                        
						if	(send_rvcb == 1'b1) 	
						begin                            
							data_i		<=	iData;
							I2C_State	<=	SEND_DATA;
						end
						else
						begin
							oData	    <=	data_i;							
						end
					end
					else					//SDA is high == Slave gave No acknowledge
					begin
						oNack		    <=	1'b1;
						I2C_State	    <=	STOP;
					end
				end
			end
			
			SEND_DATA : begin
				oAck		<=	1'b0;
				oNack		<=	1'b0;
                oReady      <=  1'b0;
				if	(bit_count < 4'h8)
				begin
					if	(tick_count	<	QUARTER_DELAY) 
					begin
						scl_oe		<=	LOW;
						tick_count	<=	( tick_count + 8'h01);
					end
						
					else if	(tick_count	<	HALF_DELAY) 
					begin
						scl_oe		<=	LOW;	
						sda_oe      <=  data_i[7];
                        sda_in      <=  ioSDA;
                        
						if (sda_in == data_i[7]) 	//Waits till signal is stable
                        begin
							tick_count	<=	(tick_count + 8'h01);
                        end
					end
						
					else if	(tick_count	<	FULL_DELAY)
					begin
                        oLED        <=  8'h80;
						scl_oe		<=	HIGH;
                        sda_oe      <=  data_i[7];
                        sda_in      <=  ioSDA;
                        tick_count	<=	(tick_count + 8'h01);
                        
					end
					else
					begin
						data_i		<=	{data_i[6:0],  1'b0};
						bit_count	<=	(bit_count +  8'h01);
						tick_count  <=  8'h00;
					end
				end
				else
                begin
					bit_count	<=	8'h00;
					scl_oe		<=	LOW;
					I2C_State	<=	ACK_DATA;
                end
			end
			
			REC_DATA : begin
				oAck			<=	1'b0;
				oNack			<=	1'b0;

				if	(bit_count	<	4'h8) 
				begin
					if	(tick_count	<	HALF_DELAY )
					begin
						scl_oe		<=	LOW;
						tick_count	<=	(tick_count	+ 8'h01);
					end
						
					else if	(tick_count	<	FULL_DELAY) 
					begin
						scl_oe		<=	HIGH;                       
						tick_count	<=	(tick_count + 8'h01);
					end
					else
					begin
						data_i		<=	{data_i[6:0], 1'b0};
						bit_count	<=	(bit_count + 8'h01);
						tick_count  <=  8'h00;
					end
				end
				else
				begin
					bit_count		<=	8'h00;
					scl_oe			<=	LOW;
					I2C_State		<=	ACK_DATA;
					oData			<=	data_i;
				end
			end	
			
			ACK_DATA:begin
                oLED                <=  8'h00;
                oReady              <=  1'b0;
                oAck                <=  1'b1;
				if (tick_count < QUARTER_DELAY) 
				begin                  
					scl_oe		    <= LOW;
                    sda_oe          <= HIGH;
                    sda_in          <= ioSDA;
					tick_count	    <=	(tick_count + 8'h01);
				end
				else if (tick_count < HALF_DELAY )
				begin
					scl_oe		    <= LOW;
					if ((send_rvcb == 1'b0) && (iHold == 1'b1))
                    begin 
						sda_oe      <= LOW;
                    end
					else
                    begin
						sda_oe  	<= HIGH;
                        sda_in      <=  ioSDA;
                    end
                    
					tick_count	<=	(tick_count + 8'h01);
				end
				else if (tick_count < FULL_DELAY) 
				begin
					scl_oe		<= HIGH;

					if ((send_rvcb == 1'b0) && (iHold == 1'b1))
                    begin
                        sda_oe      <= LOW;
                    end
					else
					begin
                        sda_oe      <= HIGH;
                        sda_in      <= ioSDA;
                    end	
					tick_count	<=	(tick_count + 8'h01);
				end
				else
                begin
                    I2C_State	    <=	HOLD;
                end
			end
			
			HOLD:begin
				oAck		<= 1'b0;
                
				if	(iHold == 1'b0) 
				begin
					tick_count  	<=  8'h00;
                    sda_oe          <=  HIGH;
                    sda_in          <=  ioSDA;
					if ((sda_in == LOW && iTransmit == 1'b1 && send_rvcb == 1'b1) || (iReceive == 1'b1 && send_rvcb == 1'b0) )
					begin
						if (send_rvcb == 1'b1) 
						begin
							data_i		    <=	iData;
							I2C_State	    <=	SEND_DATA;
						end
						else
						begin
							oData		<=	data_i;
							I2C_State	<=	REC_DATA;
						end
					end
					else
					begin
						oNack		<=	1'b1;
						I2C_State	<=	STOP;
					end
				end
			end
			
			STOP:begin
				oAck			<=	1'b0;
				oNack			<=	1'b0;

				if	(tick_count	<	QUARTER_DELAY )
				begin
					sda_oe      <=  LOW;
					scl_oe		<=	LOW;
					tick_count	<=	(tick_count + 8'h01);
				end
				else if (tick_count	<	HALF_DELAY )
				begin
					sda_oe      <=  LOW;
					scl_oe		<=	HIGH;
					tick_count	<=	(tick_count + 8'h01);
				end
				else if (tick_count	<	FULL_DELAY) 
				begin
					sda_oe		<=	HIGH;
					scl_oe		<=	HIGH;
                    sda_in      <=  ioSDA;
					if (sda_in == 1'b1) 
						tick_count	<=	(tick_count + 8'h01);
				end
				else
				begin
					sda_oe  		<=	HIGH;
					scl_oe			<=	HIGH;
					I2C_State   	<=	IDLE;
				end
			end
		endcase	
	end
end

endmodule 