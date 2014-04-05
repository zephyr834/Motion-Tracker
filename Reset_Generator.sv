/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*File: Synchronous Reset Generator
*Created by: Cory Eighan
*Date: 13 July 2012
*Revised: 
9/5/12-Changed from Active high to active low.
*Notes:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

module Reset_Generator(
input		    	iClk,
input		    	iReset_Switch,
//output		        oLed,
output		        oReset_En
);

//===================================
//			Parameters
//===================================


//====================================
//			REG/WIRE Declarations
//====================================
wire	[23:0]	counter;

//===================================
//			Port Declarations
//===================================

//====================================
//			Structural Coding
//====================================

always@(posedge iClk or posedge iReset_Switch)
begin
	if (iReset_Switch == 1'b1)
		begin
			oReset_En		    <=	1'b0;
//			oLed				<=	1'b1;
			counter			    <=	20'h1FFFF;		//~100k	--took off an F
		end
	else if	(counter > 20'h0)
		begin
			counter	            <=	(counter - 20'h1);
		end
	else
		begin
			oReset_En		    <=	1'b1;
//			oLed				<=	1'b0;
		end
end



endmodule 