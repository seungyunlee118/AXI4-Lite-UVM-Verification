# ============================================================================
# AXI4-Lite UVM Verification Environment Makefile
# Description: Automates compilation, simulation, regression, and coverage
# ============================================================================

# --- Variables ---
TEST_NAME ?= sy_test
SEED      ?= random
VERBOSITY ?= UVM_LOW
COMP_OPTS  = -sv -mfcu +incdir+../src
SIM_OPTS   = -c -do "run -all; quit" -sv_seed $(SEED) +UVM_TESTNAME=$(TEST_NAME) +UVM_VERBOSITY=$(VERBOSITY)

# --- File Paths ---
RTL_FILES = ../rtl/axi4_lite_slave.sv
TB_FILES  = ../tb/axi4_lite_if.sv ../tb/tb_top.sv
PKG_FILE  = ../src/sy_uvm_pkg.sv

# ============================================================================
# Targets
# ============================================================================

# Default target
all: clean compile run

# 1. Compile: Compile RTL design and Testbench
compile:
	@echo "--------------------------------------------------------"
	@echo " [MAKE] Compiling Source Files..."
	@echo "--------------------------------------------------------"
	vlib work
	vlog $(COMP_OPTS) $(PKG_FILE) $(RTL_FILES) $(TB_FILES)

# 2. Run: Execute a single test (Specific seed can be applied)
run:
	@echo "--------------------------------------------------------"
	@echo " [MAKE] Running Simulation (Test: $(TEST_NAME), Seed: $(SEED))"
	@echo "--------------------------------------------------------"
	vsim $(SIM_OPTS) tb_top -l sim_$(SEED).log

# 3. Regression: Run 5 consecutive simulations with multiple random seeds
regression: compile
	@echo "--------------------------------------------------------"
	@echo " [MAKE] Starting Regression Run..."
	@echo "--------------------------------------------------------"
	@for seed in 123 456 789 101 202; do \
		echo "Running seed: $$seed"; \
		vsim -c -do "coverage save -onexit cov_$$seed.ucdb; run -all; quit" \
		-sv_seed $$seed tb_top +UVM_TESTNAME=$(TEST_NAME) -l sim_$$seed.log; \
	done
	@echo " [MAKE] Regression Finished."

# 4. Coverage Merge: Merge fragmented coverage results and generate HTML report
cov_merge:
	@echo "--------------------------------------------------------"
	@echo " [MAKE] Merging Coverage Databases..."
	@echo "--------------------------------------------------------"
	vcover merge final_coverage.ucdb cov_*.ucdb
	vcover report -html final_coverage.ucdb -htmldir cov_report/
	@echo " [MAKE] Coverage Report Generated in /cov_report directory."

# 5. Clean: Remove simulation artifacts and logs
clean:
	@echo "--------------------------------------------------------"
	@echo " [MAKE] Cleaning Up Directory..."
	@echo "--------------------------------------------------------"
	rm -rf work transcript *.wlf *.log *.ucdb cov_report/