/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*File: PWM signal creator
*Created by: Cory Eighan
*Date: 24 September 2012
*Revised: None
*Credit: 
*Notes: Creates the appropriate PWM signal for servos
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

module pwm_creator (
input               iClock,
input               iReset,
input     [7:0]     iXduty,
input     [7:0]     iYduty,
output    [7:0]     oLED,
output              oXpwm,
output              oYpwm
);

//===================================
//			Parameters
//===================================


//Note: Duty cycle will be between 8%-12% incrementing by .1%
parameter           NEGATIVE    = 1'b0;

parameter           TENTH_DUTY   = 24'h3E8;
parameter           FREQ_50DUTY  = 24'h0F4240; // 50 Hz
parameter           ONE_DUTY     = 20'h04E20; //1%  of 50 Hz
parameter           EIGHT_DUTY   = 20'h13880; //8% of 50Hz

//====================================
//			REG/WIRE Declarations
//====================================

reg     [23:0]      counter;
reg                 counter_flag;
reg     [23:0]      x_duty;
reg     [23:0]      y_duty;
wire    [23:0]      tempx;
wire    [23:0]      tempy;
wire    [23:0]      shiftx;
wire    [23:0]      shifty;

//===================================
//			Port Declarations
//===================================

//===================================
//			Structural Coding
//===================================

initial
begin
    counter         <=  24'h0;
end

//TODO: Add condition to stop PWM signal based on change of x,y coordinates
always@(posedge iClock or negedge iReset)
begin
    if (iReset == 1'b0)
    begin
        counter         <= 24'h000000;
        oXpwm           <= 1'b0;
        oYpwm           <= 1'b0;
        oLED            <= 8'hF;
    end
    
    else
    begin
     //   oLED            <=  x_duty[7:0];
        
        if (counter >= FREQ_50DUTY)
            counter         <=  24'h000000;
        else
            counter         <=  (counter + 24'h000001);
            
            
        if (counter <= x_duty)
            oXpwm           <=  1'b1;   
        else
            oXpwm           <=  1'b0;
            
        if (counter <= y_duty)
            oYpwm           <=  1'b1;
        else
            oYpwm           <=  1'b0;
        
        oLED                <=  iXduty;
        tempx               <=  iXduty;
        tempy               <=  iYduty;
        shiftx              <=  (tempx << 4'hC);   //range from 8%-12% with .2% increments
        shifty              <=  (tempy << 4'hC); 
        
        x_duty              <=  (shiftx + EIGHT_DUTY);   //range from 8%-12% with .2% increments
        y_duty              <=  (shifty + EIGHT_DUTY);
    end
    
end

endmodule 