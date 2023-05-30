onerror {exit -code 1}
vlib work
vlog -work work alarm_clock_entity.vo
vlog -work work clock_module_vvf_sim.vwf.vt
vsim -novopt -c -t 1ps -L cyclonev_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.clock_module_vlg_vec_tst -voptargs="+acc"
vcd file -direction alarm_clock_entity.msim.vcd
vcd add -internal clock_module_vlg_vec_tst/*
vcd add -internal clock_module_vlg_vec_tst/i1/*
run -all
quit -f
