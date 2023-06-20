onerror {exit -code 1}
vlib work
vlog -work work vga_rgb.vo
vlog -work work vga_test_sim.vwf.vt
vsim -novopt -c -t 1ps -L cyclonev_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.main_vga_module_vlg_vec_tst -voptargs="+acc"
vcd file -direction vga_rgb.msim.vcd
vcd add -internal main_vga_module_vlg_vec_tst/*
vcd add -internal main_vga_module_vlg_vec_tst/i1/*
run -all
quit -f
