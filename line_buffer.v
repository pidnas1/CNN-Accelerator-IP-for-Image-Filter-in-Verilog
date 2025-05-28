`timescale 1ns / 1ps

module linebuf(
input   i_clk,
input   i_rst,
input [7:0] i_data,
input   i_data_valid,
output [39:0] o_data,
input i_rd_data
);

reg [7:0] line [511:0]; 
reg [8:0] wrPntr;
reg [8:0] rdPntr;

always @(posedge i_clk)
begin
    if(i_data_valid)
        line[wrPntr] <= i_data;
end

always @(posedge i_clk)
begin
    if(i_rst)
        wrPntr <= 'd0;
    else if(i_data_valid)
        wrPntr <= wrPntr + 'd1;
end

assign o_data = {line[rdPntr],line[rdPntr+1],line[rdPntr+2], line[rdPntr+3], line[rdPntr+4]};

always @(posedge i_clk)
begin
    if(i_rst)
        rdPntr <= 'd0;
    else if(i_rd_data)
        rdPntr <= rdPntr + 'd1;
end
endmodule
