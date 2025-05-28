`timescale 1ns / 1ps
module test();
    `define headerSize 1080
    `define imageSize 512*512
    reg clk;
    reg reset;
    reg [7:0] imgData;
    reg [7:0] image[0:24];  
    reg imgDataValid;
    reg kernelMode;
    integer file, file1, i,file2 ;
    integer sentSize;
    integer receivedData = 0; 
    wire intr;
    wire [7:0] outData;
    wire [20:0] convoledoutData;
    
    wire outDataValid;

    // Clock Generation
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end
    // Kernel Loading Phase
    initial begin
        // Load kernel
        $readmemb("kernel.mem", image);
        // Reset system
        reset = 0;
        imgDataValid = 0;
        kernelMode = 1;
        #1000;
        reset = 1;
        #1000;
        // Send kernel
        for (i = 0; i < 25; i = i + 1) begin
            @(posedge clk);
            imgData <= image[i];
            imgDataValid <= 1'b1;
            $display("Kernel %0d: %b", i, image[i]);
        end
        @(posedge clk);
        imgDataValid <= 1'b0;
        // End kernel phase
        kernelMode <= 0;
    end
    // Image Sending Phase
    initial begin
        sentSize = 0;
        wait(reset == 1);
        wait(kernelMode == 0);
        file =  $fopen("lena_gray.bmp", "rb");
        file1 = $fopen("blurred_lena.bmp", "wb");
        file2 = $fopen("imageData.h", "w");
        // Write BMP header
        for (i = 0; i < `headerSize; i = i + 1) begin
            $fscanf(file, "%c", imgData);
            $fwrite(file1, "%c", imgData);
        end

        // Send 6 line buffers
        for (i = 0; i < 6 * 512; i = i + 1) begin
            @(posedge clk);
            $fscanf(file, "%c",    imgData);
            $fwrite(file2, "%0d,", imgData);
            imgDataValid <= 1'b1;
        end
        sentSize = 6 * 512;
        @(posedge clk);
        imgDataValid <= 1'b0;
        // Send remaining lines
        while (sentSize < `imageSize) begin
            @(posedge intr);
            for (i = 0; i < 512; i = i + 1) begin
                @(posedge clk);
                $fscanf(file, "%c", imgData); 
                $fwrite(file2, "%0d,", imgData);
                imgDataValid <= 1'b1;
            end
            @(posedge clk);
            imgDataValid <= 1'b0;
            sentSize = sentSize + 512;
        end
        // Dummy line 1
        @(posedge clk);
        imgDataValid <= 1'b0;
        @(posedge intr);
        for (i = 0; i < 512; i = i + 1) begin
            @(posedge clk);
            imgData <= 0;
            imgDataValid <= 1'b1;
            $fwrite(file2, "%0d,", 0);
        end
        // Dummy line 2
        @(posedge clk);
        imgDataValid <= 1'b0;
        @(posedge intr);
        for (i = 0; i < 512; i = i + 1) begin
            @(posedge clk);
            imgData <= 0;
            imgDataValid <= 1'b1;
            $fwrite(file2, "%0d,", 0);
        end
        @(posedge clk);
        imgDataValid <= 1'b0;
        $fclose(file);
        $fclose(file2);
    end

    // Write output
    always @(posedge clk) begin
        if (outDataValid) begin
            $fwrite(file1, "%c", outData);
            receivedData = receivedData + 1;
        end
        if (receivedData == `imageSize) begin
            $fclose(file1);
            $stop;
        end
    end
    assign outData=convoledoutData/25;
    // DUT instantiation
    test_top dut (
        .axi_clk(clk),
        .axi_reset_n(reset),
        .i_data_valid(imgDataValid),
        .i_data(imgData),
        .i_kernel_mode(kernelMode),
        .o_data_valid(outDataValid),
        .o_data(convoledoutData),
        .o_intr(intr)
    );
endmodule
