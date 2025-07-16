
set clk_net [get_nets -hierarchical *clk*]
change_selection -add $clk_net
gui_set_highlight_options -current_color red
gui_highlight_nets_of_selected



