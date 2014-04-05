/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*File: Frame_Array
*Created by: Cory Eighan
*Date: 24 October 2012
*Revised: 
*Description: This is main module for getting ref frame and comparing frames. This also
*does tracking of coordinates for the object if there is a difference.
*Notes: 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

module frame_array (
iClock,
iReset,
iYdata,
iEnLatch,
iMemData,
iHref,
iNewFrame,
iReadyFlag,
oReadEn,
oMemAddr,
oNewCoord,
oLED,
oWriteEn,
oMemData,
oXmin,
oXmax,
oYmin,
oYmax
);

input		    	iClock;
input		    	iReset;
input     [7:0]     iYdata;
input               iEnLatch;
input     [3:0]     iMemData;
input               iHref;
input               iNewFrame;
input               iReadyFlag;
output              oReadEn;
output    [14:0]    oMemAddr;
output              oNewCoord;
output    [7:0]     oLED;
output              oWriteEn;
output    [3:0]     oMemData;
output    [7:0]     oXmin;
output    [7:0]     oXmax;
output    [7:0]     oYmin;
output    [7:0]     oYmax;
//===================================
//			Parameters
//===================================

parameter   FRAME_END     =  16'h57C0; //16'h4B00;     QCIF = 18C0; QVGA = 4B00
parameter   ROW_SIZE      =  8'h9A;   //320 = 9'b1_0100_0000; 176 = 8'hB0
parameter   COL_SIZE      =  8'h90;
   
//====================================
//			REG/WIRE Declarations
//====================================
reg          [3:0]    frames_done;
reg          [7:0]    diff_counter;
reg          [7:0]    row_counter;
reg          [7:0]    pixel_counter;
reg          [7:0]    col_counter;
reg                   enlatch_old;
reg                   href_old;
reg                   diff_flag;
reg          [7:0]    delay;
wire         [3:0]    ydata;
wire         [3:0]    pixel_diff;
wire         [4:0]    add_result;
wire         [4:0]    avg_result;
wire         [3:0]    mem_temp;
reg          [3:0]    memout_temp;
wire         [14:0]   mem_addr;
//these are to store frame x and y location when a difference is found between 2 frames
reg           [7:0]    xmin;            
reg           [7:0]    xmax;
reg           [7:0]    xmin_temp;            
reg           [7:0]    xmax_temp;
reg           [7:0]    ymin;
reg           [7:0]    ymax;

reg           [7:0]    counter;
reg                    frame_sync;

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
        xmin            <=  8'h9A;
        xmax            <=  8'h00;
        ymin            <=  8'h90;
        ymax            <=  8'h00;
        oXmin           <=  8'h4E;
        oXmax           <=  8'h4E;
        oYmin           <=  8'h48;
        oYmax           <=  8'h48;
        row_counter     <=  8'h00;
        col_counter     <=  8'h00;
        diff_counter    <=  8'h00;
        diff_flag       <=  1'b0;
        delay           <=  8'h00;
        frames_done     <=  1'b0;
        enlatch_old     <=  1'b0;
        oWriteEn        <=  1'b0;
        oLED            <=  8'hFF;
        oNewCoord       <=  1'b0;
        counter         <=  8'h00;
        frame_sync      <=  1'b0;
        
    end
    
    else if (iReadyFlag == 1'b1)
    begin
        if (iNewFrame == 1'b1)
        begin           
            if (diff_flag == 1'b1)
            begin                       
                oLED            <=  counter;
                oXmin           <=  xmin;
                oXmax           <=  xmax;
                oYmin           <=  ymin;
                oYmax           <=  ymax;
                oNewCoord       <=  1'b1;
                diff_flag       <=  1'b0;
                counter         <=  8'h00;
            end            
            if (delay == 8'h1f)
            begin
                frames_done     <=  4'h1;
            end
            else
            begin
                delay               <=  delay + 1'b1;
            end

   //         oLED                <=  col_counter;             
            diff_counter        <=  8'h00;          
            col_counter         <=  8'h00;
            xmin                <=  8'h9A;
            xmax                <=  8'h00;
            ymin                <=  8'h90;
            ymax                <=  8'h00;                          
            row_counter         <=  8'h00;
            frame_sync          <=  1'b1;
            mem_addr            <=  15'h0000;
        end
        else
        begin
            oNewCoord       <=  1'b0;
        end
        
        //Keeps track the number of rows
        if (iHref == 1'b0 && href_old == 1'b1)
        begin
            col_counter         <=  col_counter + 1'b1;
            pixel_counter       <=  8'h00;
        end
        
        href_old            <=  iHref;
        
        if ((iEnLatch == 1'b1) && (enlatch_old == 1'b0) && (frame_sync == 1'b1))
        begin
            ydata               <=  iYdata[7:4];       //downscale to 4 bits.       
            enlatch_old         <=  1'b1;
            pixel_counter       <=  pixel_counter + 1'b1;
            case(frames_done)
                0: begin
                    if (delay == 8'h1f)
                    begin
                        oWriteEn           <=  1'b1;
                        oReadEn            <=  1'b0;
                        mem_addr           <=  mem_addr + 1'b1;
                        oMemAddr           <=  mem_addr;
                        oMemData           <=  ydata;
                    end
                end

                //compares incoming frames with ref frame
                1: begin                                                           
                    oWriteEn           <=  1'b0;                    
                    mem_addr           <=  mem_addr + 1'b1;
                    oReadEn            <=  1'b1;
                    oMemAddr           <=  mem_addr;
                    mem_temp           <=  iMemData;
                    
                    row_counter        <=  row_counter + 8'h01;
                    
                    if (ydata > mem_temp)
                    begin
                        pixel_diff         <=  ydata - mem_temp;
                    end
                    else
                    begin
                        pixel_diff         <=  mem_temp - ydata;
                    end
                       
                    if (pixel_diff > 4'h2)
                    begin
                        diff_counter        <=  diff_counter + 1'b1;
                        
                        if (diff_counter == 8'h01)
                        begin
                            xmin_temp       <=  row_counter;
                        end
                        else if (diff_counter > 8'h05)
                        begin
                            diff_flag       <=  1'b1;
                            counter         <=  counter + 1'b1;
                            xmax_temp       <=  row_counter;
                            if (xmax_temp > xmax)
                            begin
                                xmax            <=  xmax_temp;
                            end
                            if (xmin_temp < xmin)
                            begin
                                xmin            <=  xmin_temp;
                            end
                        end
                    end 
                    else
                    begin
                        diff_counter        <=  8'h00;
                    end
                                                                            
                    if (row_counter == ROW_SIZE)
                    begin
                        row_counter         <=  8'h00;
                    end                                                                            
                end               
            endcase
        end
    
        else
        begin  
            enlatch_old         <=  iEnLatch;
        end
    end
end

endmodule 