transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/turboEd/Desktop/git/gitPlis/PLIS-PLD-/spiLedController/src {C:/Users/turboEd/Desktop/git/gitPlis/PLIS-PLD-/spiLedController/src/counter.v}

vlog -vlog01compat -work work +incdir+C:/Users/turboEd/Desktop/git/gitPlis/PLIS-PLD-/spiLedController/src/../sim {C:/Users/turboEd/Desktop/git/gitPlis/PLIS-PLD-/spiLedController/src/../sim/onlyCounter_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  onlyCounter_tb

add wave *
view structure
view signals
run -all
