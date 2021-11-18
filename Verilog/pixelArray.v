

module pixelArray(
   input logic          VBN1,
   input logic          RAMP,
   input logic          RESET,
   input logic          ERASE,
   input logic          EXPOSE,

   input logic   READ1,
   input logic   READ2,
   
   inout [7:0]     pixData1,
   inout [7:0]     pixData2,
   inout [7:0]     pixData3,
   inout [7:0]     pixData4

);
    //dv_pixel is assigned different values for the differnet pixels to differentiate the results from each other.
    parameter real   dv_pixel1 = 0.5;
    parameter real   dv_pixel2 = 0.4;
    parameter real   dv_pixel3 = 0.7;
    parameter real   dv_pixel4 = 0.8;

    //instantiate the four pixels
    PIXEL_SENSOR #(.dv_pixel(dv_pixel1)) ps1(VBN1, RAMP, RESET, ERASE, EXPOSE,  READ1,  pixData1);
    PIXEL_SENSOR #(.dv_pixel(dv_pixel2)) ps2(VBN1, RAMP, RESET, ERASE, EXPOSE,  READ1,  pixData2);
    PIXEL_SENSOR #(.dv_pixel(dv_pixel3)) ps3(VBN1, RAMP, RESET, ERASE, EXPOSE,  READ2,  pixData3);
    PIXEL_SENSOR #(.dv_pixel(dv_pixel4)) ps4(VBN1, RAMP, RESET, ERASE, EXPOSE,  READ2,  pixData4);
    

endmodule