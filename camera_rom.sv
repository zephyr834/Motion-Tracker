/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*File: D-Latch
*Created by: Cory Eighan
*Date: 06 August 2012
*Revised: None
*Notes:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

module camera_rom(
	input 		    		iClock,
	input					iEn,
	input		[7:0]		iAddr,
	output	    [15:0]	    oData
);

//===================================
//			Parameters
//===================================


//====================================
//			REG/WIRE Declarations
//====================================
	
//===================================
//			Port Declarations
//===================================


//====================================
//			Structural Coding
//====================================

always@(posedge iClock)
begin
	if (iEn == 1'b1)
    begin
        case(iAddr)
            0:begin
                oData       <=  16'h1280;
            end           
            1:begin
                oData       <=  16'h1408; //  Com9 Gain control 08 - 2x
                                                        //      18 - 4x
                                                        //      28 - 8x
                                                        //      38 - 16x
                                                        //      68 - 128x
                                                        //      78 - Not Allowed                                 
            end
            2:begin
                oData       <=  16'h3A10;       //TSLB
            end
            3:begin
                oData       <=  16'h1208;   //COM7  QCIF = 08  QVGA = 10
            end
            4:begin
                oData       <=  16'h0C08;
            end
            5:begin
                oData       <=  16'h3D80;
            end
            ///Added
            6:begin
                oData       <=  16'h0F4B;   //
            end
            7:begin                
                oData       <=  16'h1140;   //ClkRC Uses external clock
            end
            8:begin
                oData       <=  16'h0900;   //Output drive x1
            end
            
        endcase    
    end
end 

endmodule 