/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*File: D-Latch
*Created by: Cory Eighan
*Date: 06 August 2012
*Revised: None
*Notes:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

module d_latch(
	input		[7:0]		iData,
	input					iClock,
	input					iReset,
	input					iEn,
	output	    [7:0]		oData
);

//===================================
//			Parameters
//===================================

//====================================
//			REG/WIRE Declarations
//====================================
reg		[7:0]			Q;
reg						en_flag;

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
			Q		<=	8'h00;
		end
    else
    begin
        if (iEn == 1'b1 && en_flag == 1'b0)
            begin
                en_flag 		<=	1'b1;
                Q				<=	iData;
            end
        else if (iEn == 1'b0)
            begin
                en_flag 		<=	1'b0;
            end
		
        oData		<=		Q;
    end
end 

endmodule 