`timescale 1ns / 1ps
module test_top (
    input        axi_clk,
    input        axi_reset_n,
    // Slave interface
    input        i_data_valid,
    input  [7:0] i_data,
    input        i_kernel_mode,
       // Master interface
    output       o_data_valid,
    output [20:0] o_data,
       // Interrupt
    output       o_intr
);

    // Internal wires
    wire [199:0] pixel_data;
    wire         pixel_data_valid;  
    wire  [20:0]  convolved_data;
    wire         convolved_data_valid;

       // ========= Kernel Buffer =========
    reg [7:0] kernel_reg [0:24];         // 5x5 = 25-element kernel
    reg [4:0] kernel_index = 0;
    reg       kernel_loaded = 0;

    wire [199:0] kernel_data;            // <--- Packed version

    // Pack kernel_reg into 200-bit wire for mac module
    assign kernel_data = {
        kernel_reg[24], kernel_reg[23], kernel_reg[22], kernel_reg[21], kernel_reg[20],
        kernel_reg[19], kernel_reg[18], kernel_reg[17], kernel_reg[16], kernel_reg[15],
        kernel_reg[14], kernel_reg[13], kernel_reg[12], kernel_reg[11], kernel_reg[10],
        kernel_reg[9],  kernel_reg[8],  kernel_reg[7],  kernel_reg[6],  kernel_reg[5],
        kernel_reg[4],  kernel_reg[3],  kernel_reg[2],  kernel_reg[1],  kernel_reg[0]
    };

    // ========= Kernel Load Logic =========
    always @(posedge axi_clk or negedge axi_reset_n) begin
        if (!axi_reset_n) begin
            kernel_index <= 0;
            kernel_loaded <= 0;
        end else if (i_kernel_mode && i_data_valid) begin
            kernel_reg[kernel_index] <= i_data;
            kernel_index <= kernel_index + 1;
            if (kernel_index == 5'd24)
                kernel_loaded <= 1;
        end
    end

    // ========= Modules =========

    control IC (
        .i_clk(axi_clk),
        .i_rst(!axi_reset_n),
        .i_pixel_data(i_data),
        .i_pixel_data_valid(i_data_valid && !i_kernel_mode && kernel_loaded),
        .o_pixel_data(pixel_data),
        .o_pixel_data_valid(pixel_data_valid),
        .o_intr(o_intr)
    );

    convol conv (
        .i_clk(axi_clk),
        .i_pixel_data(pixel_data),
        .i_kernel_data(kernel_data),
        .i_pixel_data_valid(pixel_data_valid),
        .o_convolved_data(convolved_data),
        .o_convolved_data_valid(convolved_data_valid)
    );
assign o_data=convolved_data;
assign o_data_valid= convolved_data_valid;

endmodule
