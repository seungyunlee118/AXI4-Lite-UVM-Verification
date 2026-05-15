# ============================================================================
# Questa Tcl Script for UVM Compilation and Simulation
# ============================================================================

# 1. Create a logical library named 'work'
vlib work

# 2. Compile RTL and Interface
vlog ../rtl/axi4_lite_slave.sv
vlog ../tb/axi4_lite_if.sv

# 3. Compile UVM Package (Include directories must be specified)
vlog +incdir+../src ../src/sy_uvm_pkg.sv

# 4. Compile Top-level Testbench
vlog ../tb/tb_top.sv

# 5. Start simulation with full visibility (+acc)
# Suppress specific optimization warnings for cleaner logs
vsim -voptargs="+acc" -sv_seed random tb_top

# 6. Add signals to the waveform window
# This command automatically pulls all signals from the virtual interface
add wave -position insertpoint sim:/tb_top/vif/*

# 7. Run the simulation until $finish is encountered
run -all