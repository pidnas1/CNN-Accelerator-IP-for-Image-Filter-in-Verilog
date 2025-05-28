`timescale 1ns / 1ps

module convol(
    input          i_clk,
    input  [199:0] i_pixel_data,
    input  [199:0] i_kernel_data,
    input          i_pixel_data_valid,
    output reg [20:0]  o_convolved_data,
    output reg        o_convolved_data_valid
); 
    reg [20:0] multData [24:0];       
    reg [20:0] sumData;
    reg        multDataValid;
    reg        sumDataValid;
     
always @(posedge i_clk) 
begin
multData[ 0] <= i_kernel_data[  7:  0] * i_pixel_data[  7:  0];
multData[ 1] <= i_kernel_data[ 15:  8] * i_pixel_data[ 15:  8];
multData[ 2] <= i_kernel_data[ 23: 16] * i_pixel_data[ 23: 16];
multData[ 3] <= i_kernel_data[ 31: 24] * i_pixel_data[ 31: 24];
multData[ 4] <= i_kernel_data[ 39: 32] * i_pixel_data[ 39: 32];
multData[ 5] <= i_kernel_data[ 47: 40] * i_pixel_data[ 47: 40];
multData[ 6] <= i_kernel_data[ 55: 48] * i_pixel_data[ 55: 48];
multData[ 7] <= i_kernel_data[ 63: 56] * i_pixel_data[ 63: 56];
multData[ 8] <= i_kernel_data[ 71: 64] * i_pixel_data[ 71: 64];
multData[ 9] <= i_kernel_data[ 79: 72] * i_pixel_data[ 79: 72];
multData[10] <= i_kernel_data[ 87: 80] * i_pixel_data[ 87: 80];
multData[11] <= i_kernel_data[ 95: 88] * i_pixel_data[ 95: 88];
multData[12] <= i_kernel_data[103: 96] * i_pixel_data[103: 96];
multData[13] <= i_kernel_data[111:104] * i_pixel_data[111:104];
multData[14] <= i_kernel_data[119:112] * i_pixel_data[119:112];
multData[15] <= i_kernel_data[127:120] * i_pixel_data[127:120];
multData[16] <= i_kernel_data[135:128] * i_pixel_data[135:128];
multData[17] <= i_kernel_data[143:136] * i_pixel_data[143:136];
multData[18] <= i_kernel_data[151:144] * i_pixel_data[151:144];
multData[19] <= i_kernel_data[159:152] * i_pixel_data[159:152];
multData[20] <= i_kernel_data[167:160] * i_pixel_data[167:160];
multData[21] <= i_kernel_data[175:168] * i_pixel_data[175:168];
multData[22] <= i_kernel_data[183:176] * i_pixel_data[183:176];
multData[23] <= i_kernel_data[191:184] * i_pixel_data[191:184];
multData[24] <= i_kernel_data[199:192] * i_pixel_data[199:192];

  multDataValid <= i_pixel_data_valid;
end

 reg signed [20:0] layer1 [0:12];
always @(posedge i_clk)  begin
layer1[0]  <= multData[0]  + multData[1];
layer1[1]  <= multData[2]  + multData[3];
layer1[2]  <= multData[4]  + multData[5];
layer1[3]  <= multData[6]  + multData[7];
layer1[4]  <= multData[8]  + multData[9];
layer1[5]  <= multData[10] + multData[11];
layer1[6]  <= multData[12] + multData[13];
layer1[7]  <= multData[14] + multData[15];
layer1[8]  <= multData[16] + multData[17];
layer1[9]  <= multData[18] + multData[19];
layer1[10] <= multData[20] + multData[21];
layer1[11] <= multData[22] + multData[23];
layer1[12] <= multData[24];         
  end
  
reg signed [20:0] layer2 [0:6];

always @(posedge i_clk) begin
          layer2[0] <= layer1[0] + layer1[1];
          layer2[1] <= layer1[2] + layer1[3];
          layer2[2] <= layer1[4] + layer1[5];
          layer2[3] <= layer1[6] + layer1[7];
          layer2[4] <= layer1[8] + layer1[9];
          layer2[5] <= layer1[10] + layer1[11]; 
          layer2[6] <= layer1[12];           
        end

reg signed [20:0] layer3[0:3];

always @(posedge i_clk) begin
                layer3[0] <= layer2[0] + layer2[1];
                layer3[1] <= layer2[2] + layer2[3];
                layer3[2] <= layer2[4] + layer2[5];
                layer3[3] <= layer2[6];
            end
    
 reg signed [20:0] layer4[0:1];
    always @(posedge i_clk ) begin
                layer4[0] <= layer3[0] + layer3[1];
                layer4[1] <= layer3[2] + layer3[3];
                end
  
 always @(posedge i_clk) begin
        sumData <= layer4[0] + layer4[1];
        sumDataValid <= multDataValid;
    end
always @(posedge i_clk) begin
        o_convolved_data       <= sumData ;
        o_convolved_data_valid <= sumDataValid;
    end

endmodule
