/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*File: Pixel Counter
*Created by: Cory Eighan
*Date: 22 September 2012
*Revised: None
*Description: Counts number of pixels and rows
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

module pixel_counter (
input				iClock,
input				iReset,
input               iVsync,
input               iHref,
input               iReadyFlag,
input               iPclk,
input      [7:0]    iPdata,
output              oNewFrame,
output     [7:0]    oLED

);

//===================================
//			Parameters
//===================================


//====================================
//			REG/WIRE Declarations
//====================================
reg     [11:0]      pixel_counter;
reg     [7:0]       href_counter;
reg     [3:0]       count;
reg                 href_old;
reg                 vsync_old;
reg                 pclk_old;
reg             y_pixel;



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
        href_old            <=  1'b0;
        href_counter        <=  8'h00;
        pixel_counter       <=  8'h00;
  //      oLED                <=  8'h00;
    end
        
    else if(iReadyFlag == 1'b1)
    begin 
       if (iHref == 1'b1)
       begin
            if (iPclk == 1'b1 && pclk_old == 1'b0)
            begin
                pixel_counter       <=  pixel_counter + 1'b1;              
            end
            
            
            if (pixel_counter == 12'h04E && href_counter == 8'h48)
            begin
                oLED                <=  iPdata;
            end
                
       end
       else if (iHref == 1'b0 && href_old == 1'b1)
       begin
  //          oLED                <=  pixel_counter[8:1];            
            pixel_counter       <=  8'h00;
       end
    
       if (iHref == 1'b1 && href_old == 1'b0)
       begin
            href_counter        <=  href_counter + 1'b1;
       end
       else if (iVsync == 1'b1 && vsync_old == 1'b0)
       begin
   //         oLED                <=  href_counter;
            oNewFrame           <=  1'b1;
            href_counter        <=  8'h00;
       end
       else
       begin
            oNewFrame           <=  1'b0;
       end
       href_old         <=  iHref;
       vsync_old        <=  iVsync;
       pclk_old         <=  iPclk;
    end  
end 

endmodule 