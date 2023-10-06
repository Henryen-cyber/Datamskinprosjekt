#Define target part and create output directory
set partNum xc7a35ticsg324-1L
set outputDir OPT
set topModule spi_interface
file mkdir $outputDir
set files [glob -nocomplain "$outputDir/*"]
if {[llength $files] != 0} {
	#clear folder contetnts
	puts "### Clearing $outputDir ###"
	file delete -force {*}[glob -directory $outputDir *];
} else {
	puts "### $outputDir is clear ###"
}

#Reference HDL and constraints source files
read_verilog -sv [glob SRC/rtl/*.sv]
#read_vhdl -library 	usrDefLib [glob ../SRC/*.vhdl]
read_xdc XDC/Arty-Master.xdc

#Run synthesis
synth_design -top $topModule -part $partNum
write_checkpoint -force $outputDir/post_synth.dcp
report_timing_summary -file $outputDir/post_synth_timing_summary.rpt
report_utilization -file $outputDir/post_synth_util.rpt

#Run optimization
opt_design
place_design
report_clock_utilization -file $outputDir/clock_util.rpt

#Get timing vialation and run optimizations if needed
if {[get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]] < 0} {
	puts "### Found Timing Vialations ###"
	puts "### Running Physical Optimizations ###"
	phys_opt_design
}

write_checkpoint -force $outputDir/post_place.dcp
report_utilization -file $outputDir/post_place_util.rpt
report_timing_summary -file $outputDir/post_place_timing_summary.rpt

#Route Design and Generate Bitstream
route_design -directive Explore
write_checkpoint -force $outputDir/post_route.dcp
report_route_status -file $outputDir/port_route_status.rpt
report_timing_summary -file $outputDir/post_route_timing_summary.rpt
report_power -file $outputDir/post_route_power.rpt
report_drc -file $outputDir/post_imp_drc.rpt
write_verilog -force $outputDir/ray_trace_impl_netlist.sv -mode timesim -sdf_anno true
write_bitstream -force $outputDir/raytrace.bit
