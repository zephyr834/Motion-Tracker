/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*File: Blob Center
*Created by: Cory Eighan
*Date: 22 September 2012
*Revised: None
*Description: Calculates center from detected blob 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

module blob_center (
input				iClock,
input				iReset,
input     [7:0]     iXmin,
input     [7:0]     iXmax,
input     [7:0]     iYmin,
input     [7:0]     iYmax,
input               iNewCoord,
output    [7:0]     oLED,
output    [7:0]     oXduty,
output    [7:0]     oYduty
);

//===================================
//			Parameters
//===================================


//====================================
//			REG/WIRE Declarations
//====================================

wire        [8:0]     sumx;
wire        [8:0]     sumy;
wire        [8:0]     avgx;
wire        [8:0]     avgy;
wire        [7:0]     tempx;
wire        [7:0]     tempy;
reg         [7:0]     newx;
reg         [7:0]     newy;
reg         [24:0]    delay_coord;



//===================================
//			Port Declarations
//===================================


//===================================
//			Structural Coding
//===================================

always@(posedge iClock or negedge iReset)
begin
    if ( iReset == 1'b0)
    begin
        newx        <=  8'h45;
        newy        <=  8'h45;
    end
        
    else 
    begin
        if (iNewCoord == 1'b1 && delay_coord == 25'h08F0000)
        begin
            delay_coord   <=  25'h0000000;
            sumx          <=  (iXmax + iXmin);
            sumy          <=  (iYmax + iYmin);            
            
            tempx         <=  sumx[8:1];    //same as shift by 1
            tempy         <=  sumy[8:1];
            
            newx          <=  (tempx >> 3'h4) + 8'h01;
            newy          <=  (tempy >> 3'h4) + 8'h01;      
        end
        else if (delay_coord != 25'h08F0000)
        begin
            delay_coord     <=  delay_coord + 1'b1;
        end
       
        oXduty        <=   newx;    
        oYduty        <=   newy;
     end
end 

endmodule 