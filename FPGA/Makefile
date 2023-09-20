bit : 
	vivado -mode batch -nolog -nojournal -source RayTrace.tcl

.PHONY : program
program : 
	vivado -mode tcl -nolog -nojournal -source program_fpga.tcl -tclargs OPT/raytrace.bit

.PHONY : clean
clean : 
	rm *.log *.jou *.xml *.html
