`timescale 1ns / 1ps
module control(
input                    i_clk,
input                    i_rst,
input [7:0]              i_pixel_data,
input                    i_pixel_data_valid,
output reg [199:0]       o_pixel_data,
output                   o_pixel_data_valid,
output reg               o_intr
);

reg [8:0] pixelCounter;  //to count 512 pixels we used 9 bit pixelcounter.
reg [2:0] currentWrLineBuffer;
reg [5:0] lineBuffDataValid;
reg [5:0] lineBuffRdData;
reg [2:0] currentRdLineBuffer;
wire [39:0] lb0data;
wire [39:0] lb1data;
wire [39:0] lb2data;
wire [39:0] lb3data;
wire [39:0] lb4data;
wire [39:0] lb5data;
reg [8:0] rdCounter;
reg rd_line_buffer;
reg [11:0] totalPixelCounter;
reg rdState;

localparam IDLE = 'b0,
           RD_BUFFER = 'b1;

assign o_pixel_data_valid = rd_line_buffer;

always @(posedge i_clk)
begin
    if(i_rst)
        totalPixelCounter <= 0;
    else
    begin
        if(i_pixel_data_valid & !rd_line_buffer)
            totalPixelCounter <= totalPixelCounter + 1;
        else if(!i_pixel_data_valid & rd_line_buffer)
            totalPixelCounter <= totalPixelCounter - 1;
    end
end

always @(posedge i_clk)
begin
    if(i_rst)
    begin
        rdState <= IDLE;
        rd_line_buffer <= 1'b0;
        o_intr <= 1'b0;
    end
    else
    begin
        case(rdState)
            IDLE:begin
                o_intr <= 1'b0;
                if(totalPixelCounter >= 2560)  //to start read opeartion we need 2560 pixels atleast e.g 5 Line Buffers are full
                begin
                    rd_line_buffer <= 1'b1;
                    rdState <= RD_BUFFER;
                end
            end
            RD_BUFFER:begin
                if(rdCounter == 511)
                begin
                    rdState <= IDLE;
                    rd_line_buffer <= 1'b0;
                    o_intr <= 1'b1; //line buffer is free make intr high
                end
            end
        endcase
    end
end
    
always @(posedge i_clk)
begin
    if(i_rst)
        pixelCounter <= 0;
    else 
    begin
        if(i_pixel_data_valid)
            pixelCounter <= pixelCounter + 1;
    end
end

//Overflow logic
always @(posedge i_clk)
begin
    if(i_rst)
        currentWrLineBuffer <= 0;
    else
    begin
        if(pixelCounter == 511 & i_pixel_data_valid)   // already reached 511 pixels and then 512 th pixels will go to next LineBuff
            currentWrLineBuffer <= currentWrLineBuffer+1;
    end
end

always @(*)
begin
    lineBuffDataValid = 6'h0;  //all of them is 0 except current line buffer
    lineBuffDataValid[currentWrLineBuffer] = i_pixel_data_valid;
end

always @(posedge i_clk)
begin
    if(i_rst)
        rdCounter <= 0;
    else 
    begin
        if(rd_line_buffer)
            rdCounter <= rdCounter + 1;
    end
end

always @(posedge i_clk)
begin
    if(i_rst)
    begin
        currentRdLineBuffer <= 0;
    end
    else
    begin
        if(rdCounter == 511 & rd_line_buffer)
            currentRdLineBuffer <= currentRdLineBuffer + 1;
    end
end

always @(*)
begin
    case(currentRdLineBuffer)
        0:begin
            o_pixel_data = {lb4data,lb3data,lb2data,lb1data,lb0data};
        end
        1:begin
            o_pixel_data = {lb5data,lb4data,lb3data,lb2data,lb1data};
        end
        2:begin
            o_pixel_data = {lb0data,lb5data,lb4data,lb3data,lb2data};
        end
        3:begin
            o_pixel_data = {lb1data,lb0data,lb5data,lb4data,lb3data};
        end
        4: begin 
            o_pixel_data = {lb2data,lb1data,lb0data,lb5data,lb4data};
        end
        5: begin 
            o_pixel_data = {lb3data,lb2data,lb1data,lb0data,lb5data};
        end
        //// case 6, 7 will follow case 5 to preserve the o_pixel_data from last 6th pixel output e.g o_pixel_data
        default: begin 
           o_pixel_data =  {lb3data,lb2data,lb1data,lb0data,lb5data};
        end
    endcase
end

always @(*)
begin
    case(currentRdLineBuffer)
        0:begin
            lineBuffRdData[0] = rd_line_buffer;
            lineBuffRdData[1] = rd_line_buffer;
            lineBuffRdData[2] = rd_line_buffer;
            lineBuffRdData[3] = rd_line_buffer;
            lineBuffRdData[4] = rd_line_buffer;
            lineBuffRdData[5] = 1'b0;
        end
       1:begin
            lineBuffRdData[0] = 1'b0;
            lineBuffRdData[1] = rd_line_buffer;
            lineBuffRdData[2] = rd_line_buffer;
            lineBuffRdData[3] = rd_line_buffer;
            lineBuffRdData[4] = rd_line_buffer;
            lineBuffRdData[5] = rd_line_buffer;
            
        end
       2:begin
             lineBuffRdData[0] = rd_line_buffer;
             lineBuffRdData[1] = 1'b0;
             lineBuffRdData[2] = rd_line_buffer;
             lineBuffRdData[3] = rd_line_buffer;
             lineBuffRdData[4] = rd_line_buffer;
             lineBuffRdData[5] = rd_line_buffer;
       end  
      3:begin
             lineBuffRdData[0] = rd_line_buffer;
             lineBuffRdData[1] = rd_line_buffer;
             lineBuffRdData[2] = 1'b0;
             lineBuffRdData[3] = rd_line_buffer;
             lineBuffRdData[4] = rd_line_buffer;
             lineBuffRdData[5] = rd_line_buffer;
       end    
      4:begin
             lineBuffRdData[0] = rd_line_buffer;
             lineBuffRdData[1] = rd_line_buffer;
             lineBuffRdData[2] = rd_line_buffer;
             lineBuffRdData[3] = 1'b0;
             lineBuffRdData[4] = rd_line_buffer;
             lineBuffRdData[5] = rd_line_buffer;
       end
      5: begin  
             lineBuffRdData[0] = rd_line_buffer;
             lineBuffRdData[1] = rd_line_buffer;
             lineBuffRdData[2] = rd_line_buffer;
             lineBuffRdData[3] = rd_line_buffer;
             lineBuffRdData[4] = 1'b0;
             lineBuffRdData[5] = rd_line_buffer;
      end 
      // case 6, 7 will follow case 5 to preserve the read from last 6th line buffer 
      default: begin  
            lineBuffRdData[0] = rd_line_buffer;
            lineBuffRdData[1] = rd_line_buffer;
            lineBuffRdData[2] = rd_line_buffer;
            lineBuffRdData[3] = rd_line_buffer;
            lineBuffRdData[4] = 1'b0;
            lineBuffRdData[5] = rd_line_buffer;
     end
      
    endcase
end
    
linebuf lB0(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(i_pixel_data),
    .i_data_valid(lineBuffDataValid[0]),
    .o_data(lb0data),
    .i_rd_data(lineBuffRdData[0])
 ); 
 
 linebuf lB1(
     .i_clk(i_clk),
     .i_rst(i_rst),
     .i_data(i_pixel_data),
     .i_data_valid(lineBuffDataValid[1]),
     .o_data(lb1data),
     .i_rd_data(lineBuffRdData[1])
  ); 
  
  linebuf lB2(
      .i_clk(i_clk),
      .i_rst(i_rst),
      .i_data(i_pixel_data),
      .i_data_valid(lineBuffDataValid[2]),
      .o_data(lb2data),
      .i_rd_data(lineBuffRdData[2])
   ); 
   
   linebuf lB3(
       .i_clk(i_clk),
       .i_rst(i_rst),
       .i_data(i_pixel_data),
       .i_data_valid(lineBuffDataValid[3]),
       .o_data(lb3data),
       .i_rd_data(lineBuffRdData[3])
    );    
    
    linebuf lB4(
       .i_clk(i_clk),
       .i_rst(i_rst),
       .i_data(i_pixel_data),
       .i_data_valid(lineBuffDataValid[4]),
       .o_data(lb4data),
       .i_rd_data(lineBuffRdData[4])
    );    
    linebuf lB5(
       .i_clk(i_clk),
       .i_rst(i_rst),
       .i_data(i_pixel_data),
       .i_data_valid(lineBuffDataValid[5]),
       .o_data(lb5data),
       .i_rd_data(lineBuffRdData[5])
    );    
    
endmodule
