set script_dir [file dirname [info script]]
puts $script_dir
cd $script_dir/..

set src_root ./src
set test_root ./test
set xdc_root ./xdc

set proj_name MagnetHarp
set source_fileset sources_1
set sim_fileset sim_1
set contraint_fileset constrs_1

# Close project if it is already open
close_project -quiet
create_project -force $proj_name ./proj -part xc7a35tcpg236-1

set proj [get_projects $proj_name]

set_property "target_language" "VHDL" $proj

add_files -fileset $source_fileset $src_root
add_files -fileset $sim_fileset $test_root
add_files -fileset $contraint_fileset $xdc_root

# Use VHDL 2008
set_property file_type {VHDL 2008} [get_files *.vhd]

# Disable synthesis of testbenches
set_property used_in_synthesis false [get_files -of [get_filesets $sim_fileset]]

set_property top magnet_harp [get_filesets sources_1]
