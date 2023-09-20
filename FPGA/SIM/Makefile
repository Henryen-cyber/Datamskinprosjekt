SOURCES_SV := \
    ../SRC/spi_interface.sv \
    ../SRC/spi_tb.sv \

COMP_OPTS_SV := \
    --incr \
    --relax \

DEFINES_SV :=
COMP_OPTS_VHDL := --incr --relax

TB_TOP := tb

#==== Default target - running simulation without drawing waveforms ====#
.PHONY : simulate
simulate : $(TB_TOP)_snapshot.wdb

.PHONY : elaborate
elaborate : .elab.timestamp

.PHONY : compile
compile : .comp_sv.timestamp 
#==== WAVEFORM DRAWING ====#
.PHONY : waves
waves : $(TB_TOP)_snapshot.wdb
	@echo
	@echo "### OPENING WAVES ###"
	xsim --gui $(TB_TOP)_snapshot.wdb

#==== SIMULATION ====#
$(TB_TOP)_snapshot.wdb : .elab.timestamp
	@echo
	@echo "### RUNNING SIMULATION ###"
	xsim $(TB_TOP)_snapshot -tclbatch xsim_cfg.tcl

#==== ELABORATION ====#
.elab.timestamp : .comp_sv.timestamp 
	@echo
	@echo "### ELABORATING ###"
	xelab -debug all -top $(TB_TOP) -snapshot $(TB_TOP)_snapshot
	touch .elab.timestamp

#==== COMPILING SYSTEMVERILOG ====#
ifeq ($(SOURCES_SV),)
.comp_sv.timestamp :
	@echo
	@echo "### NO SYSTEMVERILOG SOURCES GIVEN ###"
	@echo "### SKIPPED SYSTEMVERILOG COMPILATION ###"
    touch .comp_sv.timestamp
else
.comp_sv.timestamp : $(SOURCES_SV) .sub_$(SUB).timestamp
	@echo
	@echo "### COMPILING SYSTEMVERILOG ###"
	xvlog --sv $(COMP_OPTS_SV) $(DEFINES_SV) $(SOURCES_SV)
	touch .comp_sv.timestamp
endif

.PHONY : clean
clean :
	rm -rf *.jou *.log *.pb *.wdb xsim.dir
	rm -rf .*.timestamp

#==== Subtractor type marker generation ===#
.sub_$(SUB).timestamp :
	@rm -rf .sub_*.timestamp
	@touch .sub_$(SUB).timestamp

