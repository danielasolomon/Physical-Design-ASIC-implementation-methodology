connect_pg_net -net VDD [get_pins -physical_context *VDD]
connect_pg_net -net VSS [get_pins -physical_context *VSS]

############################ IO ring ############################

create_pg_ring_pattern ring_pat -horizontal_layer M9 \
-horizontal_width {6} -horizontal_spacing {2} \
-vertical_layer M8 -vertical_width {6} \
-vertical_spacing {2} -corner_bridge false

set_pg_strategy ring_strat -core \
-pattern {{name: ring_pat} {nets: {VDD VSS}}{offset: {2 2}} {parameters: {M8 6 2 M9 6 2 true}}} 
#-extension {{stop: design_boundary}}

compile_pg -strategies ring_strat -ignore_drc
# compile_pg -undo

############################ M7 -> M2 ############################

#{{vertical_layer: M6} {width: 2}{spacing: interleaving} {pitch: 32}} \ 

create_pg_mesh_pattern mesh_pat -layers { \
{{horizontal_layer: M7} {width: 2}{spacing: interleaving} {pitch: 32}} \
{{horizontal_layer: M5} {width: 2}{spacing: interleaving} {pitch: 28.8}} \
{{vertical_layer: M4} {width: 2}{spacing: interleaving} {pitch: 28.8}} \
{{horizontal_layer: M3} {width: 2}{spacing: interleaving} {pitch: 28.8}} \
{{vertical_layer: M2} {width: 2}{spacing: interleaving} {pitch: 10}}} \
-via_rule { \
{{layers: M5} {layers: M4} {via_master: default}} \
{{layers: M4} {layers: M3} {via_master: default}} \
{{layers: M3} {layers: M2} {via_master: default}}} 

set_pg_strategy mesh_strat -core -pattern {{name: mesh_pat} {nets: {VDD VSS}}}

compile_pg -strategies mesh_strat -ignore_drc



############################ M6 poly 1 ############################

create_pg_mesh_pattern mesh_pat_M6_poly1 -layers { \
{{vertical_layer: M6} {width: 2}{spacing: interleaving} {pitch: 32}}} \
-via_rule { \
{{layers: M7} {layers: M6} {via_master: default}} \
{{layers: M6} {layers: M5} {via_master: default}}}

set_pg_strategy mesh_strat_M6_poly1 -polygon {{220 250} {250 1384.6}} -pattern {{name: mesh_pat_M6_poly1} {nets: {VDD VSS}}}

compile_pg -strategies mesh_strat_M6_poly1 -ignore_drc



############################ M6 poly 2 ############################

create_pg_mesh_pattern mesh_pat_M6_poly2 -layers { \
{{vertical_layer: M6} {width: 2}{spacing: interleaving} {pitch: 32}}} \
-via_rule { \
{{layers: M7} {layers: M6} {via_master: default}} \
{{layers: M6} {layers: M5} {via_master: default}}}

set_pg_strategy mesh_strat_M6_poly2 -polygon {{220 220} {1384.982 250}} -pattern {{name: mesh_pat_M6_poly2} {nets: {VDD VSS}}}

compile_pg -strategies mesh_strat_M6_poly2 -ignore_drc



############################ M6 poly 3 ############################


create_pg_mesh_pattern mesh_pat_M6_poly3 -layers { \
{{vertical_layer: M6} {width: 2}{spacing: interleaving} {pitch: 32}}} \
-via_rule { \
{{layers: M7} {layers: M6} {via_master: default}} \
{{layers: M6} {layers: M5} {via_master: default}}}

set_pg_strategy mesh_strat_M6_poly3 -polygon {{1164 250} {1384.982 1384.6}} -pattern {{name: mesh_pat_M6_poly3} {nets: {VSS VDD}}}

compile_pg -strategies mesh_strat_M6_poly3 -ignore_drc



############################ M6 poly 4 ############################

create_pg_mesh_pattern mesh_pat_M6_poly4 -layers { \
{{vertical_layer: M6} {width: 2}{spacing: interleaving} {pitch: 32}}} \
-via_rule { \
{{layers: M7} {layers: M6} {via_master: default}} \
{{layers: M6} {layers: M5} {via_master: default}}}

set_pg_strategy mesh_strat_M6_poly4 -polygon {{236 480.4} {1042.875 1384.6}} -pattern {{name: mesh_pat_M6_poly4} {nets: {VSS VDD}}}

compile_pg -strategies mesh_strat_M6_poly4 -ignore_drc


############################ M6 poly 5 ############################

create_pg_mesh_pattern mesh_pat_M6_poly5 -layers { \
{{vertical_layer: M6} {width: 2}{spacing: interleaving} {pitch: 32}}} \
-via_rule { \
{{layers: M7} {layers: M6} {via_master: default}} \
{{layers: M6} {layers: M5} {via_master: default}}}

set_pg_strategy mesh_strat_M6_poly5 -polygon {{1036 1345} {1169.267 1384.6}} -pattern {{name: mesh_pat_M6_poly5} {nets: {VSS VDD}}}

compile_pg -strategies mesh_strat_M6_poly5 -ignore_drc


############################ M6 poly 6 ############################

create_pg_mesh_pattern mesh_pat_M6_poly6 -layers { \
{{vertical_layer: M6} {width: 2}{spacing: interleaving} {pitch: 32}}} \
-via_rule { \
{{layers: M7} {layers: M6} {via_master: default}} \
{{layers: M6} {layers: M5} {via_master: default}}}

set_pg_strategy mesh_strat_M6_poly6 -polygon {{1036 247} {1169.267 1097.2}} -pattern {{name: mesh_pat_M6_poly6} {nets: {VSS VDD}}}

compile_pg -strategies mesh_strat_M6_poly6 -ignore_drc



############################ M6 poly 7 ############################

create_pg_mesh_pattern mesh_pat_M6_poly7 -layers { \
{{vertical_layer: M6} {width: 2}{spacing: interleaving} {pitch: 32}}} \
-via_rule { \
{{layers: M7} {layers: M6} {via_master: default}} \
{{layers: M6} {layers: M5} {via_master: default}}}

set_pg_strategy mesh_strat_M6_poly7 -polygon {{876 248} {1037 484}} -pattern {{name: mesh_pat_M6_poly7} {nets: {VSS VDD}}}

compile_pg -strategies mesh_strat_M6_poly7 -ignore_drc























############### Rails #######################

create_pg_std_cell_conn_pattern rail_pat -layers {M1} \
-rail_width {0.094 0.094}

set_pg_strategy rail_strat -core \
-pattern {{name: rail_pat} {nets: VDD VSS}}

compile_pg -strategies rail_strat -ignore_drc



###################### pg mesh for memories f#######################

#create_pg_macro_conn_pattern macro_pat -nets {VDD VSS} \
#-direction horizontal -width 1 -layers M7 -spacing minimum \
#-pitch 5 -pin_conn_type long_pin
#
#set_pg_strategy macro_strat -core \
#-pattern {{name: macro_pat} {nets: VDD VSS}}

#compile_pg -strategies macro_strat -ignore_drc

#################pg mesh special for channels ( in case channel width is not enough)##########
#create_pg_special_pattern channel_pattern \
#-insert_channel_straps {{layer: M6} {direction: vertical} \{width: 2} \{channel_between_objects: {macro placement_blockage voltage_area} \}}


#get_attribute [get_vias -filter { net_type == ground || net_type == power   && lower_layer_name == M1 && upper_layer_name == M2 } ]
#get_attribute [get_shapes -filter { net_type == ground || net_type == power   && layer_name == M2 } ]
#get_attribute [get_vias -filter { net_type == ground || net_type == power   && cut_layer_names == VIA2 } ]






