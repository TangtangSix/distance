
package require ::quartus::project


set_location_assignment PIN_E15 -to rst_n
set_location_assignment PIN_E1 -to clk

set_location_assignment PIN_G15 -to led[0]
set_location_assignment PIN_F16 -to led[1]
set_location_assignment PIN_F15 -to led[2]
set_location_assignment PIN_D16 -to led[3]

set_location_assignment PIN_E16 -to key

set_location_assignment PIN_A4 -to sel[0]
set_location_assignment PIN_B4 -to sel[1]
set_location_assignment PIN_A3 -to sel[2]
set_location_assignment PIN_B3 -to sel[3]
set_location_assignment PIN_A2 -to sel[4]
set_location_assignment PIN_B1 -to sel[5]
set_location_assignment PIN_B7 -to seg[0]
set_location_assignment PIN_A8 -to seg[1]
set_location_assignment PIN_A6 -to seg[2]
set_location_assignment PIN_B5 -to seg[3]
set_location_assignment PIN_B6 -to seg[4]
set_location_assignment PIN_A7 -to seg[5]
set_location_assignment PIN_B8 -to seg[6]
set_location_assignment PIN_A5 -to seg[7]


set_location_assignment PIN_A14 -to rgb_b[4]
set_location_assignment PIN_B14 -to rgb_b[3]
set_location_assignment PIN_A15 -to rgb_b[2]
set_location_assignment PIN_B16 -to rgb_b[1]
set_location_assignment PIN_C15 -to rgb_b[0]


set_location_assignment PIN_A11 -to rgb_g[5]
set_location_assignment PIN_B11 -to rgb_g[4]
set_location_assignment PIN_A12 -to rgb_g[3]
set_location_assignment PIN_B12 -to rgb_g[2]
set_location_assignment PIN_A13 -to rgb_g[1]
set_location_assignment PIN_B13 -to rgb_g[0]

set_location_assignment PIN_C8 -to rgb_r[4]
set_location_assignment PIN_A9 -to rgb_r[3]
set_location_assignment PIN_B9 -to rgb_r[2]
set_location_assignment PIN_A10 -to rgb_r[1]
set_location_assignment PIN_B10 -to rgb_r[0]

set_location_assignment PIN_C16 -to h_sync
set_location_assignment PIN_D15 -to v_sync

set_location_assignment PIN_M2  -to rx_data
set_location_assignment PIn_G1  -to tx_data

set_location_assignment PIN_C9 -to echo
set_location_assignment PIN_D9 -to trig

set_location_assignment PIN_J1 -to beep

