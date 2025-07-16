#set FILL_CELL [get_lib_cells *FILL*]
#set FILL_CELL [get_object_name $FILL_CELL]
#
#foreach FC $FILL_CELL {
#	set name [get_attribute $FC full_name]
#	set width [get_attribute $FC width]
#	set height [get_attribute $FC height]
#	puts "$name"
#	puts "$width"
#	puts "$height"
#}
#
#
#set CORNER_CELL [get_lib_cells *CORN*]
#set CORNER_CELL [get_object_name $CORNER_CELL]
#
#foreach CO $CORNER_CELL {
#	set name [get_attribute $CO full_name]
#	set width [get_attribute $CO width]
#	set height [get_attribute $CO height]
#	puts "$name"
#	puts "$width"
#	puts "$height"
#}

############ PLACE CORNERES ############

create_cell corner_NW saed14io_fc_frame_timing_ccs/CORNER/frame
create_cell corner_NE saed14io_fc_frame_timing_ccs/CORNER/frame
create_cell corner_SE saed14io_fc_frame_timing_ccs/CORNER/frame
create_cell corner_SW saed14io_fc_frame_timing_ccs/CORNER/frame

set llc_die [lindex [get_attribute [current_design ] boundary] 0]
set ulc_die [lindex [get_attribute [current_design ] boundary] 1]
set urc_die [lindex [get_attribute [current_design ] boundary] 2]
set lrc_die [lindex [get_attribute [current_design ] boundary] 3]


############ Coordinates for die area ######
set llc_die [lindex [get_attribute [current_design ] boundary] 0]
set ulc_die [lindex [get_attribute [current_design ] boundary] 1]
set urc_die [lindex [get_attribute [current_design ] boundary] 2]
set lrc_die [lindex [get_attribute [current_design ] boundary] 3]


# Coord (x, y)
set x_ll [lindex $llc_die 0]
set y_ll [lindex $llc_die 1]

set x_ul [lindex $ulc_die 0]
set y_ul [lindex $ulc_die 1]

set x_ur [lindex $urc_die 0]
set y_ur [lindex $urc_die 1]

set x_lr [lindex $lrc_die 0]
set y_lr [lindex $lrc_die 1]

# Dim. corner
set corner_cell [get_object_name [get_lib_cells *CORN*]]
set corner_w [get_attribute $corner_cell width]
set corner_h [get_attribute $corner_cell height]

set_cell_location -coordinates "$x_ll $y_ll" -orientation R270 corner_SE
set_attribute [get_cells corner_SE] physical_status fixed

set_cell_location -coordinates "[expr $x_lr - $corner_w] $y_lr" -orientation R0 corner_SW
set_attribute [get_cells corner_SW] physical_status fixed

set_cell_location -coordinates "[expr $x_ul] [expr $y_ul - $corner_h]" -orientation R180 corner_NW
set_attribute [get_cells corner_NW] physical_status fixed

set_cell_location -coordinates "[expr $x_ur - $corner_w] [expr $y_ur - $corner_h]" -orientation R90 corner_NE
set_attribute [get_cells corner_NE] physical_status fixed






############ POWER IO CELLS + FILLERS ############ 

# South-North
set vdd_cell_N "saed14io_fc_frame_timing_ccs/IOVDD_NS/frame"
set vss_cell_N "saed14io_fc_frame_timing_ccs/IOVSS_NS/frame"

# East-West
set vdd_cell_E "saed14io_fc_frame_timing_ccs/IOVDD_EW/frame"
set vss_cell_E "saed14io_fc_frame_timing_ccs/IOVSS_EW/frame"

# IO Fillers
set io_fillers {
    {"saed14io_fc_frame_timing_ccs/FILLER5/frame" 5}
    {"saed14io_fc_frame_timing_ccs/FILLER1/frame" 1}
    {"saed14io_fc_frame_timing_ccs/FILLER01/frame" 0.1}
}





####################### SE ####################### 

# Coord:start x = ultimul pad-25, end x = origine corner + width corner
set start_x [expr 260.5 - 25.0]
set end_x   [expr $x_ll + $corner_w]
#pt ca merg invers
set available_width [expr $start_x - $end_x]


# place vdd vss vdd vss until there is no space - each one has 25
set current_x $start_x
set current_y $y_ll
set i 0

while { [expr $current_x ] >= $end_x } {
    if {[expr $i % 2] == 0} {
        set cell_name power_io_VSS_SE_$i
        set cell_type $vss_cell_N
    } else {
        set cell_name power_io_VDD_SE_$i
        set cell_type $vdd_cell_N
    }

    create_cell $cell_name $cell_type

    set_cell_location -coordinates "$current_x $current_y" -orientation R0 $cell_name
    set_attribute [get_cells $cell_name] physical_status fixed

    set current_x [expr {$current_x - 25.0}]
    incr i
}


set remaining_width [expr $current_x + 25.0 - $end_x]
set current_x [expr {$current_x + 25.0}]

set i 0

foreach filler $io_fillers {
    
    set filler_name [lindex $filler 0]
    set filler_w [lindex $filler 1]

    set count [expr {int($remaining_width / $filler_w)}]

    for {set j 0} {$j < $count} {incr j} {
        set cell_name io_filler_SE_${i}_${j}
        create_cell $cell_name $filler_name
        set current_x [expr $current_x - $filler_w]
        set_cell_location -coordinates "$current_x $current_y" -orientation R0 $cell_name
        set_attribute [get_cells $cell_name] physical_status fixed
        
    }

    set remaining_width [expr $current_x  - $end_x]
    incr i
}




####################### NE ####################### 

# Coord:start x = ultimul pad-25, end x = origine corner + width corner
set start_y 1345
set end_y   [expr $y_ul - $corner_w]
#pt ca merg invers
set available_width [expr $end_y - $start_y]


# place vdd vss vdd vss until there is no space - each one has 25
set current_x $x_ul
set current_y $start_y
set i 0

while { [expr $current_y + 25 ] <= $end_y } {
    if {[expr $i % 2] == 0} {
        set cell_name power_io_VSS_NE_$i
        set cell_type $vss_cell_E
    } else {
        set cell_name power_io_VDD_NE_$i
        set cell_type $vdd_cell_E
    }

    create_cell $cell_name $cell_type

    set_cell_location -coordinates "$current_x $current_y" -orientation R180 $cell_name
    set_attribute [get_cells $cell_name] physical_status fixed

    set current_y [expr {$current_y + 25.0}]
    incr i
}


set remaining_width [expr $end_y - $current_y]

set i 0

foreach filler $io_fillers {
    
    set filler_name [lindex $filler 0]
    set filler_w [lindex $filler 1]

    set count [expr {int($remaining_width / $filler_w)}]

    for {set j 0} {$j < $count} {incr j} {
        set cell_name io_filler_NE_${i}_${j}
        create_cell $cell_name $filler_name
        
        set_cell_location -coordinates "$current_x $current_y" -orientation R270 $cell_name
        set_attribute [get_cells $cell_name] physical_status fixed
        set current_y [expr $current_y + $filler_w]
    }
    if {$filler_w == 0.1} {
        set cell_name io_filler_NE_${i}_${j}
        create_cell $cell_name $filler_name
        set_cell_location -coordinates "$current_x $current_y" -orientation R270 $cell_name
        set_attribute [get_cells $cell_name] physical_status fixed
        set current_y [expr $current_y + $filler_w]
    }
    set remaining_width [expr $end_y  - $current_y]

    incr i
}














####################### NW ####################### 

# Coord:start x = ultimul pad-25, end x = origine corner + width corner
set start_x 1270
set end_x   [expr $x_ur - $corner_w]
#pt ca merg invers
set available_width [expr $end_x - $start_x]


# place vdd vss vdd vss until there is no space - each one has 25
set current_x $start_x
set current_y [expr $y_ur - 200]
set i 0

while { [expr $current_x + 25 ] <= $end_x } {
    if {[expr $i % 2] == 0} {
        set cell_name power_io_VSS_NW_$i
        set cell_type $vss_cell_N
    } else {
        set cell_name power_io_VDD_NW_$i
        set cell_type $vdd_cell_N
    }

    create_cell $cell_name $cell_type

    set_cell_location -coordinates "$current_x $current_y" -orientation R180 $cell_name
    set_attribute [get_cells $cell_name] physical_status fixed

    set current_x [expr {$current_x + 25.0}]
    incr i
}


set remaining_width [expr $end_x - $current_x]

set current_y [expr $current_y + 1.5]

set i 0

foreach filler $io_fillers {
    
    set filler_name [lindex $filler 0]
    set filler_w [lindex $filler 1]

    set count [expr {int($remaining_width / $filler_w)}]

    for {set j 0} {$j < $count} {incr j} {
        set cell_name io_filler_NW_${i}_${j}
        create_cell $cell_name $filler_name
        
        set_cell_location -coordinates "$current_x $current_y" -orientation R180 $cell_name
        set_attribute [get_cells $cell_name] physical_status fixed
        set current_x [expr $current_x + $filler_w]
    }

    set remaining_width [expr $end_x  - $current_x]

    incr i
}









####################### SW ####################### 

# Coord:start x = ultimul pad-25, end x = origine corner + width corner
set start_y 259.6
set end_y   [expr $y_lr + $corner_w]
#pt ca merg invers
set available_width [expr $start_y - $end_y]


# place vdd vss vdd vss until there is no space - each one has 25
set current_x 1405.5
set current_y $start_y
set i 0

while { [expr $current_y - 25 ] >= $end_y } {
    if {[expr $i % 2] == 0} {
        set cell_name power_io_VSS_SW_$i
        set cell_type $vss_cell_E
    } else {
        set cell_name power_io_VDD_SW_$i
        set cell_type $vdd_cell_E
    }

    create_cell $cell_name $cell_type
    set current_y [expr {$current_y - 25.0}]
    set_cell_location -coordinates "$current_x $current_y" -orientation R0 $cell_name
    set_attribute [get_cells $cell_name] physical_status fixed

    
    incr i
}


set remaining_width [expr $current_y - $end_y]
set current_x [expr $current_x + 1.5]
set i 0

foreach filler $io_fillers {
    
    set filler_name [lindex $filler 0]
    set filler_w [lindex $filler 1]

    set count [expr {int($remaining_width / $filler_w)}]

    for {set j 0} {$j < $count} {incr j} {
        set cell_name io_filler_SW_${i}_${j}
        create_cell $cell_name $filler_name
        
        set current_y [expr $current_y - $filler_w]
        set_cell_location -coordinates "$current_x $current_y" -orientation R90 $cell_name
        set_attribute [get_cells $cell_name] physical_status fixed
        
    }

    if {$filler_w == 0.1} {
        set cell_name io_filler_SW_${i}_${j}
        create_cell $cell_name $filler_name
        set current_y [expr $current_y - $filler_w]
        set_cell_location -coordinates "$current_x $current_y" -orientation R90 $cell_name
        set_attribute [get_cells $cell_name] physical_status fixed
        
    }

    set remaining_width [expr $current_y - $end_y]

    incr i
}












######################### FILLERS BETWEEN IO PADS AND CORNERS ##############
for {set k 0} {$k < 4} {incr k} {
    set remaining_width 20
    

    if {$k == 0} {
        set current_x 0
        set current_y 200

        set end_y [expr {$current_x + 20}]

        foreach filler $io_fillers {

            set filler_name [lindex $filler 0]
            set filler_w [lindex $filler 1]

            set count [expr {int($remaining_width / $filler_w)}]

            for {set j 0} {$j < $count} {incr j} {
                set cell_name io_filler_between_cornerIOpad_${k}_${j}
                create_cell $cell_name $filler_name

                set_cell_location -coordinates "$current_x $current_y" -orientation R270 $cell_name
                set_attribute [get_cells $cell_name] physical_status fixed
                set current_y [expr $current_y + $filler_w]
            }

            set remaining_width [expr $end_y  - $current_y]
            
        }
    } elseif {$k == 1} {
        set current_x 200
        set current_y 1406.1

        set end_x [expr {$current_x + 20}]

        foreach filler $io_fillers {

            set filler_name [lindex $filler 0]
            set filler_w [lindex $filler 1]

            set count [expr {int($remaining_width / $filler_w)}]

            for {set j 0} {$j < $count} {incr j} {
                set cell_name io_filler_between_cornerIOpad_${k}_${j}
                create_cell $cell_name $filler_name

                set_cell_location -coordinates "$current_x $current_y" -orientation R180 $cell_name
                set_attribute [get_cells $cell_name] physical_status fixed
                set current_x [expr $current_x + $filler_w]
            }

            set remaining_width [expr $end_x  - $current_x]
            
            }
    } elseif {$k == 2} {
        set current_x 1407
        set current_y 1404.6

        set end_y [expr {$current_y - 20}]

        foreach filler $io_fillers {

            set filler_name [lindex $filler 0]
            set filler_w [lindex $filler 1]

            set count [expr {int($remaining_width / $filler_w)}]

            for {set j 0} {$j < $count} {incr j} {
                set cell_name io_filler_between_cornerIOpad_${k}_${j}
                create_cell $cell_name $filler_name
                set current_y [expr $current_y - $filler_w]
                set_cell_location -coordinates "$current_x $current_y" -orientation R90 $cell_name
                set_attribute [get_cells $cell_name] physical_status fixed
                
            }

            set remaining_width [expr $current_y  - $end_y]
            
            }
    } elseif {$k == 3} {
        set current_x 1405.5
        set current_y 0

        set end_x [expr {$current_x - 20}]

        foreach filler $io_fillers {

            set filler_name [lindex $filler 0]
            set filler_w [lindex $filler 1]

            set count [expr {int($remaining_width / $filler_w)}]

            for {set j 0} {$j < $count} {incr j} {
                set cell_name io_filler_between_cornerIOpad_${k}_${j}
                create_cell $cell_name $filler_name
                set current_x [expr $current_x - $filler_w]
                set_cell_location -coordinates "$current_x $current_y" -orientation R0 $cell_name
                set_attribute [get_cells $cell_name] physical_status fixed
                
            }

            set remaining_width [expr $current_x - $end_x]
            
            }
    }  

}




create_bound -name "Bound_For_congestion" -boundary {{220 390} {1385 1160}} -color "#72c4f1" [get_cells -hier *]
create_placement_blockage -name BLK_FOR_BOUND -type partial -blocked_percentage 60 -boundary {{220 390} {1385 1160}}

puts "S-A CREAT BLOCAJ"


set_app_options -name place.coarse.max_density -value 0.15
set_app_options -name place.coarse.congestion_driven_max_util -value 0.20


set_app_options -name opt.timing.effort -value low;# tool default low; set qor strategy default high
set_app_options -name opt.power.effort -value low ;# tool default low;

set_app_options -name place.coarse.enhanced_low_power_effort -value none ;# tool default low; RM default low
set_app_options -name place.coarse.congestion_analysis_effort -value low
set_app_options -name place_opt.initial_place.effort -value low
set_app_options -name place_opt.place.congestion_effort -value none
set_app_options -name place_opt.initial_drc.global_route_based -value 0
set_app_options -name place_opt.final_place.effort -value low

set_app_options -name compile.early_place.effort -value low
set_app_options -name compile.final_place.effort -value low
set_app_options -name compile.flow.high_effort_timing -value 0
set_app_options -name compile.initial_place.effort -value low



puts "S-A CREAT APP_OPTIONS"



#puts "\n-- Placing Cells ---"
#set current_y [lindex [lindex [get_attribute [get_cell [lindex $corner_cells 0]] bbox] 1] 1]
#set remaining_length $total_length
#set current_x $start_x
#set current_y $start_y
#set total_used_length 0
#foreach cell $cells {
#    puts "processing cell $cell"
#    set bbox [get_attribute [get_cell $cell] bbox]
#    #set_attribute [get_cell $cell] orientation $orientation_cell
#    set cell_width [expr {[lindex [lindex $bbox 1] 0] - [lindex [lindex $bbox 0] 0]}]
#    set cell_height [expr {[lindex [lindex $bbox 1] 1] - [lindex [lindex $bbox 0] 1]}]
#    set cell_length [expr {$dx != 0 ? $cell_width : $cell_height}]
#    if {$cell_length > $remaining_length} {
#        puts "Error: Not enough space to place the cell $cell on side $side"
#        break
#    }
#    #set move_x 0
#    #set move_y $current_y
#    #puts "placing IO cell: $cell at ($move_x, $move_y)"
#    move_objects [get_cell $cell] -x $current_x -y $current_y
#    set current_x [expr {$current_x + $dx * $cell_width}]
#    set current_y [expr {$current_y + $dy * $cell_height}]
#    #set current_y $move_y
#    #set total_used_length [expr {$total_used_length + $cell_height}]
#    set remaining_length [expr {$remaining_length - $cell_length}]
#}
#
#set remaining_length [expr {$remaining_length - $total_used_length}]
#puts "Placing fillers for remaining length $remaining_length"
#set fillers [calculate_fillers $remaining_length $filler_cells]
#set filler_index 0
#foreach filler $fillers {
#    create_cell -design [current_design] filler_${filler_index}_${side} $filler
#    set_attribute [get_cell filler_${filler_index}_${side}] orientation $orientation
#    set filler_bbox [get_attribute [get_cell filler_${filler_index}_${side}] bbox]
#    set filler_width [expr {[lindex [lindex $filler_bbox 1] 0] - [lindex [lindex $filler_bbox 0] 0]}]
#    set filler_height [expr {[lindex [lindex $filler_bbox 1] 1] - [lindex [lindex $filler_bbox 0] 1]}]
#    set filler_length [expr {$dx != 0 ? $filler_width : $filler_height}]
#    #set move_x 0
#    #set move_y [expr {$current_y + $filler_height}]
#    #puts "Placing filler cell: filler_${filler_index}_${side} at ($move_x, $move_y)"
#    move_objects -x $current_x -y $current_y [get_cell filler_${filler_index}_${side}]
#    set current_x [expr {$current_x + $dx * $filler_width}]
#    set current_y [expr {$current_y + $dy * $filler_height}]
#    #set current_y $move_y
#    incr filler_index
#}


