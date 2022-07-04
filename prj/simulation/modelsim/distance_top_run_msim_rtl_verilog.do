transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+G:/FPGAProject/EP4CE6F17C8/distance/src {G:/FPGAProject/EP4CE6F17C8/distance/src/sel_drive.v}
vlog -vlog01compat -work work +incdir+G:/FPGAProject/EP4CE6F17C8/distance/src {G:/FPGAProject/EP4CE6F17C8/distance/src/seg_drive.v}
vlog -vlog01compat -work work +incdir+G:/FPGAProject/EP4CE6F17C8/distance/src {G:/FPGAProject/EP4CE6F17C8/distance/src/distance_top.v}
vlog -vlog01compat -work work +incdir+G:/FPGAProject/EP4CE6F17C8/distance/src {G:/FPGAProject/EP4CE6F17C8/distance/src/distance.v}
vlog -vlog01compat -work work +incdir+G:/FPGAProject/EP4CE6F17C8/distance/ip {G:/FPGAProject/EP4CE6F17C8/distance/ip/pll.v}
vlog -vlog01compat -work work +incdir+G:/FPGAProject/EP4CE6F17C8/distance/prj/db {G:/FPGAProject/EP4CE6F17C8/distance/prj/db/pll_altpll.v}

vlog -vlog01compat -work work +incdir+G:/FPGAProject/EP4CE6F17C8/distance/prj/../sim {G:/FPGAProject/EP4CE6F17C8/distance/prj/../sim/distance_top_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  distance_top_tb

add wave *
add wave -position insertpoint sim:/distance_top_tb/u_distance_top/u_distance/*
view structure
view signals
run -all
