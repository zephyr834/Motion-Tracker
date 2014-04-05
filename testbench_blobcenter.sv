/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*File: Test Bench Blob Center
*Created by: Cory Eighan
*Date: 26 September 2012
*Revised: 
*Notes:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

module testbench_blobcenter (
input                   iClock,
input                   iReset,
output                  oNewCoord,
output      [8:0]       oXmin,
output      [8:0]       oXmax,
output      [7:0]       oYmin,
output      [7:0]       oYmax
);

//===================================
//			Parameters
//===================================


//====================================
//			REG/WIRE Declarations
//====================================
reg     [31:0]      counter;
reg     [3:0]      flag;

//===================================
//			Port Declarations
//===================================

//===================================
//			Structural Coding
//===================================

always@(posedge iClock or negedge iReset)
begin
    if (iReset == 1'b0)
    begin
        oXmin               <=  9'h00;    //2
        oXmax               <=  9'h00;    //256
        oYmin               <=  8'h00;    //2
        oYmax               <=  8'h00;    //256
    end
    
    else
    begin
        case(flag)
                0:begin
                    oXmin               <=  8'h00;    //27
                    oXmax               <=  8'h00;    //40
                end
                
                1:begin
                    oXmin               <=  8'h10;    //27
                    oXmax               <=  8'h10;    //40
                end
                
                2:begin
                    oXmin               <=  8'h20;    //27
                    oXmax               <=  8'h20;    //40
                end
                
                3:begin
                    oXmin               <=  8'h30;    //27
                    oXmax               <=  8'h30;    //40
                end
                
                4:begin
                    oXmin               <=  8'h40;    //27
                    oXmax               <=  8'h40;    //40
                end
                
                5:begin
                    oXmin               <=  8'h50;    //27
                    oXmax               <=  8'h50;    //40
                end
                
                6:begin
                    oXmin               <=  8'h60;    //27
                    oXmax               <=  8'h60;    //40
                end
                
                7:begin
                    oXmin               <=  8'h70;    //27
                    oXmax               <=  8'h70;    //40
                end
                
                8:begin
                    oXmin               <=  8'h80;    //27
                    oXmax               <=  8'h80;    //40
                end
                
                9:begin
                    oXmin               <=  8'h90;    //27
                    oXmax               <=  8'h90;    //40
                end
            endcase
        counter             <=  counter + 1'b1;
        if (counter == 32'h004F0000)
        begin
            counter         <=  32'h000000;
            flag            <=  flag + 1'b1;
            if (flag == 4'hA)
                flag    <=  4'h0;
            
            
            
        end
    end
end

endmodule 