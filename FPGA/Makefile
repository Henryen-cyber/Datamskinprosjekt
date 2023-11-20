bit : 
	vivado -mode batch -source RayTrace.tcl

.PHONY : program
program : 
	vivado -mode tcl -source program_fpga.tcl -tclargs OPT/raytrace.bit

.PHONY : clean
clean : 
	rm OPT/*.log OPT/*.jou OPT/*.xml OPT/*.html
