set_app_options -name opt.timing.effort -value low;# tool default low; set qor strategy default high
set_app_options -name opt.power.effort -value low ;# tool default low;
#set_app_options -name opt.common.use route aware estimationset_gor_strategy default high
#set_app_options -value false: # tool default false; set qor strategy default true for >16nm
#set_app_options -name place opt.initial drc.global route based -value false :# tool default false; set qor_strategy default true
#set_app_options -name place opt.final place.effort -value low :#tool default medium; set gor strategy default high
#set_app_options -name place opt.congestion.effort -value low ;# tool default medium; set qor_strategy default high

set_app_options -name place.coarse.enhanced_low_power_effort -value none ;# tool default low; RM default low
set_app_options -name place.coarse.congestion_analysis_effort -value low
set_app_options -name place_opt.initial_place.effort -value low
set_app_options -name place_opt.place.congestion_effort -value none
set_app_options -name place_opt.initial_drc.global_route_based -value 0
set_app_options -name place_opt.final_place.effort -value low

