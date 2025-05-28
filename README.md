CNN-Accelerator-for-Image-Spatial-Filter

Deliverables
The main idea of this project is to implement image spatial filtering or image processing using 5 x 5 kernel on a Zynq ZedBoard FPGA.
It involves multiple stages, from module development to simulation and generating the output image using Vitis SDK

Project Overview
1. Module Development
The image processing IP is divided into three main modules:

Line Buffer Module: This module is responsible for managing the line buffer, an essential component for image processing operations.

Convolution Module: This module performs the convolution operation using a 5 x 5 kernel to apply the Box Blur filter.

Control Logic with Line-Buffer Modules: Control logic integrates the line buffer modules and facilitates smooth image processing operations.

2. Integration and Packaging
The three modules are integrated to create a comprehensive image processing IP package.

3. Testing and Simulation
A testbench is created to simulate the IP package and verify its functionality.

4. Vitis SDK Integration
The project is opened in Vitis SDK, and the final output image is generated using the Zynq ZedBoard FPGA.
