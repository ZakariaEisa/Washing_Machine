# Create a working library (suppress warning if it already exists)
vlib work

# Compile the design and testbench with correct coverage options
vlog -cover bceft WMCONTROLLERLST.v TBWMLST.v

# Simulate the testbench (correct the module name to match `tb_wm`)
vsim -voptargs=+acc work.tb_wm -coverage

# Add all signals to the waveform
add wave *

# Save coverage data at the end of the simulation
coverage save tb_wm.ucdb -onexit

# Run the simulation
run -all
# Generate a detailed text-based coverage report
vcover report -details -output coverage_report.txt tb_wm.ucdb

# Exit the simulator after the run
quit -sim
