`timescale 1 ns / 1 ps

//====================================================================
// Testbench for pixelArray
// - clock
// - instanciate pixel
// - State Machine for controlling pixel sensor
// - Model the ADC and ADC
// - Readout of the databus
// - Stuff neded for testbench. Store the output file etc.
//====================================================================
module pixelArray_tb;

   //------------------------------------------------------------
   // Testbench clock
   //------------------------------------------------------------
   logic clk =0;
   logic reset =0;
   parameter integer clk_period = 500;
   parameter integer sim_end = clk_period*2400;
   always #clk_period clk=~clk;

   //------------------------------------------------------------
   // Pixel
   //------------------------------------------------------------
   parameter real    dv_pixel = 0.5;  //Set the expected photodiode current (0-1)

   //Analog signals
   logic anaBias1;
   logic anaRamp;
   logic anaReset;

   //Tie off the unused lines
   assign anaReset = 1;

   //Digital
   logic erase;
   logic  expose;

   logic   read1;
   logic   read2;
   //logic   read3;
   //logic   read4;

   tri[7:0]    pixData1; 
   tri[7:0]    pixData2; 
   tri[7:0]    pixData3; 
   tri[7:0]    pixData4; 
     //  We need this to be a wire, because we're tristating it
        

   //Instanciate the pixel, her lages en pixel sensor
   pixelArray A1(anaBias1,anaRamp,anaReset,erase,expose,read1,read2,pixData1,pixData2,pixData3,pixData4);


   //------------------------------------------------------------
   // State Machine
   //------------------------------------------------------------
   parameter ERASE=0, EXPOSE=1, CONVERT=2, READ1=3, READ2 = 4, IDLE=7;
 //READ3 = 5, READ4 = 6,
   logic               convert;
   logic               convert_stop;
   logic [2:0]         state,next_state;   //States
   integer           counter;            //Delay counter in state machine

   //State duration in clock cycles
   parameter integer c_erase = 5;
   parameter integer c_expose = 255;
   parameter integer c_convert = 255;
   parameter integer c_read = 5;

   // Control the output signals
   always_ff @(negedge clk ) begin
      case(state)
        ERASE: begin
           erase <= 1;
           read1 <= 0;
           read2 <= 0;
           //read3 <= 0;
           //read4 <= 0;
           expose <= 0;
           convert <= 0;
        end
        EXPOSE: begin
           erase <= 0;
           read1 <= 0;
           read2 <= 0;
           //read3 <= 0;
           //read4 <= 0;
           expose <= 1;
           convert <= 0;
        end
        CONVERT: begin
           erase <= 0;
           read1 <= 0;
           read2 <= 0;
           //read3 <= 0;
           //read4 <= 0;
           expose <= 0;
           convert = 1;
        end
        READ1: begin
           erase <= 0;
           read1 <= 1;
           read2 <= 0;
           //read3 <= 0;
           //read4 <= 0;
           expose <= 0;
           convert <= 0;
        end
        READ2: begin
           erase <= 0;
           read1 <= 0;
           read2 <= 1;
           //read3 <= 0;
           //read4 <= 0;
           expose <= 0;
           convert <= 0;
        end
        /*READ3: begin
           erase <= 0;
           read1 <= 0;
           read2 <= 0;
           read3 <= 1;
           read4 <= 0;
           expose <= 0;
           convert <= 0;
        end
        READ4: begin
           erase <= 0;
           read1 <= 0;
           read2 <= 0;
           read3 <= 0;
           read4 <= 1;
           expose <= 0;
           convert <= 0;
        end*/
        IDLE: begin
           erase <= 0;
           read1 <= 0;
           read2 <= 0;
           //read3 <= 0;
           //read4 <= 0;
           expose <= 0;
           convert <= 0;

        end
      endcase // case (state)
   end // always @ (state)


   // Control the state transitions.
   //TODO: The counter should probably be an always_comb. Might be a good idea
   //to also reset the counter from the state machine, i.e provide the count
   //down value, and trigger on 0
   always_ff @(posedge clk or posedge reset) begin
      if(reset) begin
         state = IDLE;
         next_state = ERASE;
         counter  = 0;
         convert  = 0;
      end
      else begin
         case (state)
           ERASE: begin
              if(counter == c_erase) begin
                 state <= IDLE;
                 next_state <= EXPOSE;
              end
           end
           EXPOSE: begin
              if(counter == c_expose) begin
                 state <= IDLE;
                 next_state <= CONVERT;
              end
           end
           CONVERT: begin
              if(counter == c_convert) begin
                 state <= IDLE;
                 next_state <= READ1;
              end
           end
           READ1:
             if(counter == c_read) begin
                state <= IDLE;
                next_state <= READ2;
             end
            READ2:
             if(counter == c_read) begin
                state <= IDLE;
                next_state <= ERASE;
             end
             /*
            READ3:
             if(counter == c_read) begin
                state <= IDLE;
                next_state <= READ4;
             end
            READ4:
             if(counter == c_read) begin
                state <= IDLE;
                next_state <= ERASE;
             end*/
           IDLE:
             state <= next_state;
         endcase // case (state)
         if(state == IDLE)
           counter = 0;
         else
           counter = counter + 1;
      end
   end // always @ (posedge clk or posedge reset)

   //------------------------------------------------------------
   // DAC and ADC model
   //------------------------------------------------------------
   logic[7:0] data1;
   logic[7:0] data2; 
   logic[7:0] data3;
   logic[7:0] data4; 

   // If we are to convert, then provide a clock via anaRamp
   // This does not model the real world behavior, as anaRamp would be a voltage from the ADC
   // however, we cheat
   assign anaRamp = convert ? clk : 0;

   // During expoure, provide a clock via anaBias1.
   // Again, no resemblence to real world, but we cheat.
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

   //------------------------------------------------------------
   // Testbench stuff
   //------------------------------------------------------------
   initial
     begin
        reset = 1;

        #clk_period  reset=0;

        $dumpfile("pixelArray_tb.vcd");
        $dumpvars();

        #sim_end
          $stop;

     end

endmodule // test
