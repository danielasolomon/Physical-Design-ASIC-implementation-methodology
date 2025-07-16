#SDC VERSION
set sdc_version 2.1
set period 2.22


#CLOCKS
create_clock -name clk -period $period [get_pins clk_pad/DOUT]

create_generated_clock -name clk0 -source [get_pins clk_pad/DOUT] -multiply_by 2 [get_pins pll/CLK_X2]
create_generated_clock -name clk0_2x -source [get_pins clk_pad/DOUT] -multiply_by 4 [get_pins pll/CLK_X4]


#SETUP CLOCK UNCERTAINTY 10% FROM CLOCK PERIOD
set_clock_uncertainty -setup [expr $period*0.1] [get_clocks clk] 
set_clock_uncertainty -hold 0.05 [get_clocks clk] 

# 10% din jumatate pt ca  frecv e dubla
set_clock_uncertainty -setup [expr ($period/2)*0.1] [get_clocks clk0] 
set_clock_uncertainty -hold 0.05 [get_clocks clk0] 

set_clock_uncertainty -setup [expr ($period/4)*0.1] [get_clocks clk0_2x] 
set_clock_uncertainty -hold 0.05 [get_clocks clk0_2x] 


#INPUT DELAY
set_input_delay -max 0.2 -clock clk [remove_from_collection [all_inputs] [get_ports {clk reset}]]
set_input_delay -min 0.0 -clock clk [remove_from_collection [all_inputs] [get_ports {clk reset}]]


#OUTPUT DELAY
set_output_delay -max 0.2 -clock clk [remove_from_collection [all_outputs] [get_ports {pllclk}]]
set_output_delay -min 0.0 -clock clk [remove_from_collection [all_outputs] [get_ports {pllclk}]]


set_max_delay 2 -from [get_ports {reset}]

###CPN Added to avert errors in dp_flat compile_dp step.
set_voltage 0.80 -object_list {SS.power}
set_voltage 0.00 -object_list {SS.ground}

set_voltage 1.80 -object_list {IO_SS.power}
set_voltage 0.00 -object_list {IO_SS.ground}

set_voltage 1.80 -object_list {A_SS.power}
set_voltage 0.00 -object_list {A_SS.ground}