transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Levovo20x/Documents/GitHub/EE314-Term-Project/simple_examples/Alarm_clock {C:/Users/Levovo20x/Documents/GitHub/EE314-Term-Project/simple_examples/Alarm_clock/clock_module.v}

