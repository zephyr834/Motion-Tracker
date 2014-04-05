/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*File: Test Bench Blob Center
*Created by: Cory Eighan
*Date: 26 September 2012
*Revised: 
*Notes:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

module testbench_pwm_creator (
input               iClock,
input               iReset,
output     [7:0]    oXduty,
output     [7:0]    oYduty
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

//===================================
//			Structural Coding
//===================================

always@(posedge iClock or iReset)
begin
   if (iReset == 1'b0)
    begin
        oXduty               <=  9'h00;    //2
        oYduty               <=  9'h00;    //256
    end
    
    else
    begin
        if (flag == 1'b0)
        begin
            oXduty               <=  8'h00;    //2
            oYduty               <=  8'h00;    //255
        end
        else
        begin
            oXduty               <=  8'h28;    //2
            oYduty               <=  8'h28;    //255
        end
        
        counter             <=  counter + 1'b1;
        if (counter == 32'h04FFFFFF)
        begin
            counter         <=  32'h000000;
            if (flag == 1'b0)
                flag            <= 1'b1; 
            else
                flag           <= 1'b0;
            
        end
    end
end

endmodule 