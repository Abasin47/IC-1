
ps:
	iverilog -g2012 -o pixelSensor -c pixelSensor.fl
	vvp -n pixelSensor

psfsm:
	iverilog -g2012 -o pixelSensorFsm -c pixelSensorFsm.fl
	vvp -n pixelSensorFsm


ysfsm: synth
	dot pixelSensorFsm.dot -Tpng > pixelSensorFsm.png

synth:
	yosys pixelSensorFsm.ys


pa: 
	iverilog -g2012 -o pixelArray -c pixelArray.fl
	vvp -n pixelArray

pafsm:
	iverilog -g2012 -o pixelState -c pixelState.fl
	vvp -n pixelState


ysfsm2: synth
	dot pixelState.dot -Tpng > pixelState.png

synth2:
	yosys pixelState.ys

pt:
	iverilog -g2012 -o pixelTop -c pixelTop.fl
	vvp -n pixelTop
