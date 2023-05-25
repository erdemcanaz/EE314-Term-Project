transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Levovo20x/Documents/GitHub/EE314-Term-Project/simple_examples/BCD_counter_base_9 {C:/Users/Levovo20x/Documents/GitHub/EE314-Term-Project/simple_examples/BCD_counter_base_9/d_latch_with_asynch_reset.v}
vlog -vlog01compat -work work +incdir+C:/Users/Levovo20x/Documents/GitHub/EE314-Term-Project/simple_examples/BCD_counter_base_9 {C:/Users/Levovo20x/Documents/GitHub/EE314-Term-Project/simple_examples/BCD_counter_base_9/d_flip_flop_with_asynch_reset.v}
vlog -vlog01compat -work work +incdir+C:/Users/Levovo20x/Documents/GitHub/EE314-Term-Project/simple_examples/BCD_counter_base_9 {C:/Users/Levovo20x/Documents/GitHub/EE314-Term-Project/simple_examples/BCD_counter_base_9/jkff_with_asynch_reset.v}

