
vlib work

vlog -cover bceft WMCONTROLLERLST.v TBWMLST.v

vsim -voptargs=+acc work.tb_wm -coverage

add wave *
coverage save tb_wm.ucdb -onexit
run -all

vcover report -details -output coverage_report.txt tb_wm.ucdb

quit -sim
