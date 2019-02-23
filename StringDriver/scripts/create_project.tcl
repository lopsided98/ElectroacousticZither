set script_dir [file dirname [info script]]
puts $script_dir
cd $script_dir/..

set src_root ./src
set test_root ./test
set xdc_root ./xdc

set proj_name MagnetZitherStringDriver
set source_fileset sources_1
set sim_fileset sim_1
set contraint_fileset constrs_1

# Close project if it is already open
close_project -quiet
create_project -force $proj_name ./.vivado_project -part xc7a35tcpg236-1

set proj [get_projects $proj_name]

set_property "target_language" "VHDL" $proj

add_files -fileset $source_fileset $src_root
add_files -fileset $sim_fileset $test_root
add_files -fileset $contraint_fileset $xdc_root

# Disable synthesis of testbenches
set_property used_in_synthesis false [get_files -of [get_filesets $sim_fileset]]

set_property top axi_string [get_filesets sources_1]

# Generate .bin file for configuration memory
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE 1 [get_runs impl_1]

# Package IP
set ip [ipx::package_project -root_dir ./. -vendor benwolsieffer.com -library magnet_zither -taxonomy "/Magnet_Zither" -force]
set_property version 1.0 $ip
set_property display_name "AXI4-lite String Driver" $ip
set_property description "AXI4-lite Electomagnet String Driver" $ip
ipx::create_xgui_files $ip
ipx::update_checksums $ip
ipx::save_core $ip
