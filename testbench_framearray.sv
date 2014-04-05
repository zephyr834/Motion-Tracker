/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*File: Test Bench Frame Array
*Created by: Cory Eighan
*Date: 18 November 2012
*Revised: 
*Notes:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

module testbench_framearray (
input                   iClock,
input                   iReset,
output                  oEnLatch,
output      [7:0]       oYdata

);

//===================================
//			Parameters
//===================================


//====================================
//			REG/WIRE Declarations
//====================================
reg             enlatch;
reg             flag;

//===================================
//			Port Declarations
//===================================

//===================================
//			Structural Coding
//===================================
initial
begin
    enlatch     <=  1'b0;
end
always@(posedge iClock or negedge iReset)
begin
    if (iReset == 1'b0)
    begin
        oYdata          <=  8'h00;
        oEnLatch        <=  1'b0;
    end
    
    else
    begin
        if (enlatch == 1'b0)
        begin
            enlatch         <=  1'b1;
            if (flag == 1'b0)
            begin
                oYdata          <=  8'h01;
                flag            <=  1'b1;
            end
            else
            begin
                oYdata          <=  8'hFF;
            end
        end
        else
        begin
            enlatch         <=  1'b0;
        end 
        
        oEnLatch        <=  enlatch;
        
    end
end

endmodule 