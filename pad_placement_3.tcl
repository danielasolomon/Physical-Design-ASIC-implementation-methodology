### create_floorplan using command  

set spacing 20  ; # Spacing for right side

### Get all IO_pads in a collection filtered by full_name and ref_lib_name/library_name 
set IO_Pads [get_cells -hier -filter {full_name =~ *pad* && ref_lib_name == saed14io_fc_frame_timing_ccs}]

### Sort above collection by full_name
set IO_pads_sorts [sort_collection $IO_Pads {full_name}]

### Convert the above collection into a list
set tranf_into_list [get_object_name $IO_pads_sorts ]

### Pad width --> assuming all are equal in size
set Pad_width [lindex [lsort -unique [get_attribute $IO_Pads width]] 0]
puts "Pad width: $Pad_width"
### Pad height --> assuming all are equal in size
set Pad_height [lindex [lsort -real [get_attribute $IO_Pads height]] 0]
puts "Pad height: $Pad_height" 







##########################################
##### Total pads #####
##########################################

# Get total number of pads
set total_IO_pads [llength $tranf_into_list]
puts "Total IO Pads: $total_IO_pads"

# Calculate pads per side
set pads_per_side [expr {int(ceil($total_IO_pads / 4.0))}]
puts "Pads per side: $pads_per_side"

set Pad_width_orizontal $Pad_width
set Pad_height_orizontal $Pad_height

set Pad_width_vertical $Pad_height
set Pad_height_vertical $Pad_width



set X_offset [expr $spacing + $Pad_width  ]  
set Y_offset [expr $spacing + $Pad_width  ]  

# Adjust core size based on number of pads
set X_core [expr {($pads_per_side * $Pad_width) + (2 * $spacing)}]  ; # Horizontal length
set Y_core [expr {($pads_per_side * $Pad_height) + (2 * $spacing) }] ; # Vertical length

# la core ca sa fie multiplu de 0.074, de site row, si acum nu mai am 3 zecimale, doar cate una  si voi putea folosi fillerele de 0.1
set Y_core1 [expr {($pads_per_side * $Pad_height) + (2 * $spacing) + 0.5}]

initialize_floorplan -side_length "${Y_core1} ${Y_core}" -core_offset "${X_offset} ${Y_offset}"

############ Coordinates for core area ######
set llc_core [lindex [get_attribute [current_design ] core_area_boundary] 0 ]
set ulc_core [lindex [get_attribute [current_design ] core_area_boundary] 1 ]
set urc_core [lindex [get_attribute [current_design ] core_area_boundary] 2 ]
set lrc_core [lindex [get_attribute [current_design ] core_area_boundary] 3 ]

############ Coordinates for die area ######
set llc_die [lindex [get_attribute [current_design ] boundary] 0]
set ulc_die [lindex [get_attribute [current_design ] boundary] 1]
set urc_die [lindex [get_attribute [current_design ] boundary] 2]
set lrc_die [lindex [get_attribute [current_design ] boundary] 3]




# Get Die width (for tightly placing top/bottom pads)
# set die_width [expr [lindex $urc_die 0] - [lindex $ulc_die 0]]

# Get exact pad spacing for tight placement on top/bottom
# set pad_spacing_X [expr $die_width / $pads_per_side]


##########################################
##### Place Pads on the Left Side #####
##########################################
set i 0
set Xpad1 [lindex $llc_die 0]   ; # Most left X of the die area
set Ypad1 [lindex $llc_core 1]  ; # Bottom Y of the core area 

puts "Placing pads on the left side..."
foreach pad_name [lrange $tranf_into_list 0 [expr $pads_per_side - 1]] {
    set y_position [expr $Ypad1 + $i * $Pad_height_orizontal]
    set_cell_location -coordinates "$Xpad1 $y_position" -orient R180 $pad_name
    set_attribute [get_cells $pad_name] physical_status fixed
    incr i
}

##########################################
##### Place Pads on the Right Side #####
##########################################
set j 0
set Xpad2 [lindex $lrc_die 0]   ; # Most right X of the die area
set Ypad2 [lindex $urc_core 1]  ; # Bottom Y of the core area 

puts "Placing pads on the right side..."
foreach pad_name [lrange $tranf_into_list $pads_per_side [expr $pads_per_side * 2 - 1]] {
    set y_position [expr $Ypad2 - ($j+1) * $Pad_height_orizontal ]
    set_cell_location -coordinates "[expr $Xpad2 - $Pad_width_orizontal] $y_position" -orient R0 $pad_name
    set_attribute [get_cells $pad_name] physical_status fixed
    incr j
}

##########################################
##### Place Pads on the Bottom Side #####
##########################################
set k 0
set Xpad3 [lindex $lrc_core 0]   ; # Rightmost X of the core area (bottom)
set Ypad3 [lindex $llc_die 1]   ; # Bottom Y of the die area

puts "Placing pads on the bottom side..."
foreach pad_name [lrange $tranf_into_list [expr $pads_per_side * 2] [expr $pads_per_side * 3 - 1]] {
    set x_position [expr $Xpad3 - ($k + 1) * $Pad_width_vertical]  
    set_cell_location -coordinates "$x_position $Ypad3" -orient R270 $pad_name
    set_attribute [get_cells $pad_name] physical_status fixed
    incr k
}

##########################################
##### Place Pads on the Top Side #####
##########################################
set m 0
set Xpad4 [lindex $ulc_core 0]   ; # Leftmost X of the core area (top)
set Ypad4 [lindex $ulc_die 1] ; # Top Y of the die area

puts "Placing pads on the top side..."
foreach pad_name [lrange $tranf_into_list [expr $pads_per_side * 3] end] {
    set x_position [expr $Xpad4 + $m * $Pad_width_vertical]  
    set_cell_location -coordinates "$x_position [expr $Ypad4 - $Pad_height_vertical]" -orient R90 $pad_name
    set_attribute [get_cells $pad_name] physical_status fixed
    incr m
}
















###########################################
##### Place Ports in Pads #####
###########################################


set pad_list $tranf_into_list
set port_list [get_object_name [get_ports]]
set port_layer M3
set port_size 2.0
set margin 0.0
set extra_ports1 0
set extra_ports2 0
set extra_ports3 0
set extra_ports4 0

proc normalize_name {name} {
    # Extrage ultima componentă dacă există /
    if {[regexp {.*/(.*)} $name -> last_part]} {
        set name $last_part
    }

    set name [regsub -all {[_\[\]/]} $name ""]
    set name [regsub -all {pad} $name ""]
    return [string tolower $name]
}

foreach port $port_list {
    set matched 0
    set norm_port [normalize_name $port]

    foreach pad $pad_list {
        set norm_pad [normalize_name $pad]

        if {[string match "$norm_port" $norm_pad]} {
            puts "\nMATCH: $port -> $pad"


            # Obține informațiile pad
            set bbox [get_attribute [get_cells $pad] boundary_bbox]
            
            set orient_val [ get_attribute [get_cells $pad] orientation]

            puts "=== Processing port: $port (Orientation: $orient_val) ==="

            switch -- $orient_val {
                "R180" {
                    # LEFT (R180)
                    set x2 [lindex [lindex $bbox 0] 0]
                    set y2 [lindex [lindex $bbox 0] 1]
                    set x3 $x2
                    set y3 [lindex [lindex $bbox 1] 1]


                    set half_y [expr {($y3 - $y2) / 2.0}]
                    set center_x $x2
                    set center_y [expr {$y2 + $half_y}]

                    set half_size [expr {$port_size / 2.0}]
                    set x1 [expr {$center_x             }]
                    set x2 [expr {$center_x + $port_size}]
                    set y1 [expr {$center_y - $half_size}]
                    set y2 [expr {$center_y + $half_size}]

                }
                "R90" {
                    # TOP (R90)
                    set x2 [lindex [lindex $bbox 0] 0]
                    set y2 [lindex [lindex $bbox 1] 1]
                    set x3 [lindex [lindex $bbox 1] 0]
                    set y3 $y2

                    set half_x [expr {($x3 - $x2) / 2.0}]
                    set center_x [expr {$x2 + $half_x}]
                    set center_y $y2

                    set half_size [expr {$port_size / 2.0}]
                    set x1 [expr {$center_x - $half_size}]
                    set x2 [expr {$center_x + $half_size}]
                    set y1 [expr {$center_y - $port_size}]
                    set y2 [expr {$center_y             }]

                }
                "R0" {
                    # RIGHT (R0)
                    set x2 [lindex [lindex $bbox 1] 0]
                    set y2 [lindex [lindex $bbox 0] 1]
                    set x3 $x2
                    set y3 [lindex [lindex $bbox 1] 1]

                    set half_y [expr {($y3 - $y2) / 2.0}]
                    set center_x $x2
                    set center_y [expr {$y2 + $half_y}]

                    set half_size [expr {$port_size / 2.0}]
                    set x1 [expr {$center_x - $port_size}]
                    set x2 [expr {$center_x             }]
                    set y1 [expr {$center_y - $half_size}]
                    set y2 [expr {$center_y + $half_size}]
                }
                "R270" {
                    # BOTTOM (R270)

                    set x2 [lindex [lindex $bbox 0] 0]
                    set y2 [lindex [lindex $bbox 0] 1]
                    set x3 [lindex [lindex $bbox 1] 0]
                    set y3 $y2

                    set half_x [expr {($x3 - $x2) / 2.0}]
                    set center_x [expr {$x2 + $half_x}]
                    set center_y $y2

                    set half_size [expr {$port_size / 2.0}]
                    set x1 [expr {$center_x - $half_size}]
                    set x2 [expr {$center_x + $half_size}]
                    set y1 [expr {$center_y             }]
                    set y2 [expr {$center_y + $port_size}]
                }
                default {
                    puts "  WARNING: Unsupported orientation: $orient_val"
                    return
                }
            }


            create_terminal -port $port -boundary "{{${x1} ${y1}} {${x2} ${y2}}}" -layer $port_layer
            set_attribute [get_ports $port] physical_status fixed
            set matched 1
            break
        }
    }


    if {!$matched} {
        puts "NO MATCH: $port"
    }
}



# List of remaining ports
set manual_ports_R0 {snps_scan_in_1 snps_scan_out_1 snps_scan_in_2 snps_scan_out_2 snps_scan_in_3 snps_scan_out_3}
set manual_ports_R90 {AVDD AVSS snps_scan_in_4 snps_scan_out_4 snps_scan_in_5 snps_scan_out_5 snps_scan_in_6 snps_scan_out_6 snps_scan_in_7 snps_scan_out_7 ser_rxd}
set manual_ports_R180 {snps_scan_in_8 snps_scan_out_8 snps_scan_shift_en snps_scan_shift_en_cg }
set manual_ports_R270 { VDD VDDIO VSS VSSIO}

set port_layer M3
set port_spacing 5  ;# dist between ports
set half_size [expr {$port_size / 2.0}]

# === R0 Placement (left) ===
set bbox [get_attribute [get_cells flash_re_pad] boundary_bbox]

set x0_R0 [lindex [lindex $bbox 0] 0] 
set y0_R0 [expr {[lindex [lindex $bbox 1] 1] + 10}] 


foreach port $manual_ports_R0 {

    set x1 [expr {$x0_R0}]
    set x2 [expr {$x1 + $port_size}]
    set y1 [expr {$y0_R0 - $half_size}]
    set y2 [expr {$y1 + $port_size}]

    create_terminal -port $port -boundary "{{${x1} ${y1}} {${x2} ${y2}}}" -layer $port_layer
    set_attribute [get_ports $port] physical_status fixed

    set y0_R0 [expr {$y0_R0 + $port_spacing}]
}

# === R90 Placement (up) ===
set bbox [get_attribute [get_cells we_pad] boundary_bbox]

set x0_R90 [expr {[lindex [lindex $bbox 1] 0] + 10}] 
set y0_R90 [lindex [lindex $bbox 1] 1]   ;#
set port_spacing_TOP 10

foreach port $manual_ports_R90 {
    set x1 [expr {$x0_R90 - $half_size}]
    set x2 [expr {$x1 + $port_size}]
    set y1 [expr {$y0_R90 - $port_size}]
    set y2 [expr {$y0_R90}]

    create_terminal -port $port -boundary "{{${x1} ${y1}} {${x2} ${y2}}}" -layer $port_layer
    set_attribute [get_ports $port] physical_status fixed

    set x0_R90 [expr {$x0_R90 + $port_spacing_TOP}]
}

# === R180 Placement (right) ===
set bbox [get_attribute [get_cells mem_datain_pad_16_] boundary_bbox]

set x0_R180 [lindex [lindex $bbox 1] 0] 
set y0_R180 [expr {[lindex [lindex $bbox 0] 1] - 7}] 

foreach port $manual_ports_R180 {
    set x1 [expr {$x0_R180}]
    set x2 [expr {$x1 - $port_size}]
    set y1 [expr {$y0_R180 - $half_size}]
    set y2 [expr {$y1 + $port_size}]

    create_terminal -port $port -boundary "{{${x1} ${y1}} {${x2} ${y2}}}" -layer $port_layer
    set_attribute [get_ports $port] physical_status fixed

    set y0_R180 [expr {$y0_R180 - $port_spacing_TOP}]
}

# === R270 Placement (down) ===
set bbox [get_attribute [get_cells mem_dataout_pad_29_] boundary_bbox]

set x0_R270 [expr {[lindex [lindex $bbox 0] 0] - 7}] 
set y0_R270 [lindex [lindex $bbox 0] 1]   

foreach port $manual_ports_R270 {
    set x1 [expr {$x0_R270 + $half_size}]
    set x2 [expr {$x1 - $port_size}]
    set y1 [expr {$y0_R270}]
    set y2 [expr {$y1 + $port_size}]

    create_terminal -port $port -boundary "{{${x1} ${y1}} {${x2} ${y2}}}" -layer $port_layer
    set_attribute [get_ports $port] physical_status fixed

    set x0_R270 [expr {$x0_R270 - $port_spacing_TOP}]
}


 













###########################################
##### Place Memory Cells in Core Area #####
###########################################


# Get memory cells based on the name pattern
set mem_cells [get_cells -hier -filter {full_name =~ *mem0* || full_name =~ *mem1* }]
set sort_mems [sort_collection $mem_cells full_name]
set mem_list [get_object_name $sort_mems]

# Get core area corners
set llc_core [lindex [get_attribute [current_design ] core_area_boundary] 0]
set urc_core [lindex [get_attribute [current_design ] core_area_boundary] 2]

# Parameters
set mem_spacing 20        ;# Space between memories
set keepout_margin 5      ;# Keepout margin
set offset 30            ;# Offset from left and bottom edges


# Cursor init
set x_cursor [expr {[lindex $llc_core 0] + $offset}]
set y_cursor [expr {[lindex $llc_core 1] + $offset}]


puts "Placing memory cells from bottom-left corner..."
set i 0
while {$i < [llength $mem_list]} {

    set mem0 [lindex $mem_list $i]
    set mem1 [lindex $mem_list [expr {$i + 1}]]

    set mem_w [get_attribute [get_cells $mem0 ] width]
    set mem_h [get_attribute [get_cells $mem0 ] height]
    set bbox [get_attribute [get_cells $mem0 ] boundary_bbox]
    set mem_ll [lindex $bbox 0]
    set mem_ur [lindex $bbox 1]


    set full_spacing_x [expr {$mem_w + 2 * $keepout_margin + $mem_spacing}]
    set full_spacing_y [expr {$mem_h + 2 * $keepout_margin + $mem_spacing}]

    # Dacă nu incap pe linia curenta, muta pe un nou rand
    #if { [expr {$x_cursor + $full_spacing_x}] > [lindex $urc_core 0] } {
    #    set x_cursor [expr {[lindex $llc_core 0] + $offset}]
    #    set y_cursor [expr {$y_cursor + $full_spacing_y}]
    #}


    if {$i == 0} {
        set x0 $x_cursor
    } elseif {[expr { $i %2 == 0 }]} {
        set x0 [expr ($x_cursor + $i / 2 * $full_spacing_x)]
    }

    set x1 $x0

    # Plaseaza mem0 jos
    set y0 $y_cursor 
    set_cell_location -coordinates "$x0 $y0" -orient R0 $mem0
    set_attribute [get_cells $mem0] physical_status fixed
    create_keepout_margin -type hard -outer "$keepout_margin $keepout_margin $keepout_margin $keepout_margin" [get_cells $mem0]

    # Plaseaza mem1 deasupra mem0
    set y1 [expr {$y0 + $full_spacing_y}]
    set_cell_location -coordinates "$x1 $y1" -orient R0 $mem1
    set_attribute [get_cells $mem1] physical_status fixed
    create_keepout_margin -type hard -outer "$keepout_margin $keepout_margin $keepout_margin $keepout_margin" [get_cells $mem1]

   
    incr i 2
    
}

 




 


###########################################
##### Place PLL and Big mem #####
###########################################


# Place pll
set_cell_location -coordinates "320.5170 1330.6" -orient R0 pll
create_keepout_margin -type hard -outer "$keepout_margin $keepout_margin $keepout_margin $keepout_margin" [get_cells pll]
set_attribute [get_cells pll] physical_status fixed

# Place memory
set_cell_location -coordinates "1042.8750 1097.2" -orient R0 dma_cntrl0/dma_fifo0/fifo_mem
create_keepout_margin -type hard -outer "$keepout_margin $keepout_margin $keepout_margin $keepout_margin" [get_cells dma_cntrl0/dma_fifo0/fifo_mem]
set_attribute [get_cells dma_cntrl0/dma_fifo0/fifo_mem] physical_status fixed 










###########################################
############### Polygons ##################
###########################################
 

remove_annotation_shapes -all

set mem_coords {}

# Adună coordonatele memoriilor
foreach mem $mem_list {
    set bbox [get_attribute [get_cells $mem] boundary_bbox]
    set ll [lindex $bbox 0]
    set ur [lindex $bbox 1]

    set x1 [lindex $ll 0]
    set y1 [lindex $ll 1]
    set x2 [lindex $ur 0]
    set y2 [lindex $ur 1]

    lappend mem_coords [list $x1 $y1 $x2 $y2]
}

# Funcție pentru sortare: întâi după y descrescător, apoi după x crescător
proc compare_coords {a b} {
    set y1a [lindex $a 1]
    set y1b [lindex $b 1]

    if {$y1a != $y1b} {
        return [expr {$y1a > $y1b ? -1 : 1}]
    }

    set x1a [lindex $a 0]
    set x1b [lindex $b 0]

    if {$x1a == $x1b} {
        return 0
    }
    return [expr {$x1a < $x1b ? -1 : 1}]
}

# Aplic sortarea
set sorted_mem_coords [lsort -command compare_coords $mem_coords]

# Toleranță pentru coliziuni minore
set tol 0.001

# Creez poligoane între memorii adiacente
for {set i 0} {$i < [expr {[llength $sorted_mem_coords] - 1}]} {incr i} {
    set mem1 [lindex $sorted_mem_coords $i]
    set mem2 [lindex $sorted_mem_coords [expr {$i + 1}]]

    set raw_x1 [lindex $mem1 2] ;# x2
    set raw_x2 [lindex $mem2 0] ;# x1
    set x1 [expr {min($raw_x1, $raw_x2)}]
    set x2 [expr {max($raw_x1, $raw_x2)}]
    set y1 [lindex $mem1 1]
    set y2 [lindex $mem1 3]

    set diff [expr {$x2 - $x1}]
    if {$diff <= $tol} {
        puts "Skipping small or no gap: ($raw_x1 $y1) - ($raw_x2 $y2) diff = $diff"
        continue
    }

    # Verific dacă sunt pe același rând
    set y_diff [expr abs([lindex $mem1 1] - [lindex $mem2 1])]
    if {$y_diff > 1.0} {
        puts "Skipping pair on different rows (y_diff = $y_diff)"
        continue
    }

    set poly_coords [list [list $x1 $y1] [list $x1 $y2] [list $x2 $y2] [list $x2 $y1]]

    create_poly_rect -boundary [list $poly_coords]
    create_annotation_shape -type poly -color green -annotation_points $poly_coords
    create_placement_blockage -type soft -bbox [list [list $x1 $y1] [list $x2 $y2]]

    puts "=> Polygon gap created: ($x1 $y1) - ($x2 $y2)"
}
