

module pixelTop(
    input logic clk,
    input logic reset,
    inout [7:0]     pixData1,
    inout [7:0]     pixData2,
    inout [7:0]     pixData3,
    inout [7:0]     pixData4
);
    logic read1;
    logic read2; 
    logic convert;
    logic expose; 
    logic erase; 
    logic anaBias1; 
    logic anaRamp; 
    logic anaReset; 
    logic[7:0] data1;
    logic[7:0] data2;
    logic[7:0] data3;
    logic[7:0] data4;
    

    //Instanciate the pixelarray and pixelstate
    pixelArray PA(anaBias1,anaRamp,anaReset,erase,expose,read1,read2,pixData1,pixData2,pixData3,pixData4);
    pixelState PS(.clk(clk),.reset(reset),.erase(erase),.expose(expose),.read1(read1),.read2(read2),.convert(convert));

    assign anaRamp = convert ? clk : 0;

   // During expoure, provide a clock via anaBias1.
   // A digital representation without much resemblence to real world.
   assign anaBias1 = expose ? clk : 0;

   // If we're not reading the pixData, then we should drive the bus
   assign pixData1 = read1 ? 8'bZ: data1;
   assign pixData2 = read1 ? 8'bZ: data2; 
   assign pixData3 = read2 ? 8'bZ: data3;
   assign pixData4 = read2 ? 8'bZ: data4;

   // When convert, then run a analog ramp (via anaRamp clock) and digtal ramp via
   // data bus.
   always_ff @(posedge clk or posedge reset) begin
      if(reset) begin
         data1 =0;
         data2 =0;
         data3 =0;
         data4 =0;
      end
      if(convert) begin
         data1 += 1;
         data2 += 1;
         data3 += 1;
         data4 += 1;
      end
      else begin
         data1 = 0;
         data2 = 0;
         data3 = 0;
         data4 = 0;
      end
   end // always @ (posedge clk or reset)

   //------------------------------------------------------------
   // Readout from databus
   //------------------------------------------------------------
   logic [7:0] pixelDataOut1;
   logic [7:0] pixelDataOut2;
   always_ff @(posedge clk or posedge reset) begin
      if(reset) begin
         pixelDataOut1 = 0;
         pixelDataOut2 = 0;
      end
      else begin
         if(read1) begin 
           pixelDataOut1 <= pixData1;
           pixelDataOut2 <= pixData2;
         end
         if(read2)begin 
            pixelDataOut1 <= pixData3;
            pixelDataOut2 <= pixData4;
         end 
      end
   end
    

    //wire = _net; 
    

endmodule