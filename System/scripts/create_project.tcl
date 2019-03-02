set script_dir [file dirname [info script]]
puts $script_dir
cd $script_dir/..

set src_root ./src
set test_root ./test
set xdc_root ./xdc

set proj_name MagnetZitherSystem
set source_fileset sources_1
set sim_fileset sim_1
set contraint_fileset constrs_1

# Add board files
set_param board.repoPaths [list ../vivado-boards/new/board_files]

# Close project if it is already open
close_project -quiet
create_project -force $proj_name ./.vivado_project -part xc7a35tcpg236-1

set proj [get_projects $proj_name]

set_property target_language VHDL $proj
set_property simulator_language VHDL $proj

# Use Basys3 board
set_property board_part digilentinc.com:basys3:part0:1.1 $proj

add_files -fileset $contraint_fileset $xdc_root

# Generate .bin file for configuration memory
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE 1 [get_runs impl_1]

# Add StringDriver IP
set_property ip_repo_paths ../StringDriver $proj
update_ip_catalog

# Create block diagram
set diagram_name magnet_zither
set diagram_dir ./block
set diagram_file ${diagram_dir}/${diagram_name}/${diagram_name}.bd
create_bd_design -dir $diagram_dir $diagram_name

# Clock manager
set clock_manager [create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clock_manager]
set_property -dict {
  CONFIG.CLKOUT1_USED {true}
  CONFIG.CLK_OUT1_PORT {mclk}
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {25.000}
  CONFIG.MMCM_DIVCLK_DIVIDE {1}
  CONFIG.MMCM_CLKFBOUT_MULT_F {9.125}
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {36.500}
  CONFIG.CLKOUT1_JITTER {181.828}
  CONFIG.CLKOUT1_PHASE_ERROR {104.359}
} $clock_manager

# Connect board clock to clock manager
apply_board_connection -board_interface "sys_clock" -ip_intf "clock_manager/clock_CLK_IN1" -diagram $diagram_name 

# CPU (Microblaze)
set cpu [create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:11.0 cpu]
set_property -dict {
  CONFIG.C_AREA_OPTIMIZED {0}
  CONFIG.C_D_AXI {1}
  CONFIG.C_I_AXI {0}
  CONFIG.G_TEMPLATE_LIST {8}
  CONFIG.G_USE_EXCEPTIONS {0}
  CONFIG.C_USE_MSR_INSTR {1}
  CONFIG.C_USE_PCMP_INSTR {1}
  CONFIG.C_USE_REORDER_INSTR {1}
  CONFIG.C_USE_BARREL {1}
  CONFIG.C_USE_DIV {1}
  CONFIG.C_USE_HW_MUL {2}
  CONFIG.C_USE_FPU {2}
  CONFIG.C_UNALIGNED_EXCEPTIONS {0}
  CONFIG.C_ILL_OPCODE_EXCEPTION {0}
  CONFIG.C_M_AXI_I_BUS_EXCEPTION {0}
  CONFIG.C_M_AXI_D_BUS_EXCEPTION {0}
  CONFIG.C_DIV_ZERO_EXCEPTION {0}
  CONFIG.C_FPU_EXCEPTION {0}
  CONFIG.C_PVR {0}
  CONFIG.C_NUMBER_OF_PC_BRK {1}
  CONFIG.C_NUMBER_OF_RD_ADDR_BRK {0}
  CONFIG.C_NUMBER_OF_WR_ADDR_BRK {0}
  CONFIG.C_OPCODE_0x0_ILLEGAL {0}
  CONFIG.C_USE_ICACHE {0}
  CONFIG.C_USE_DCACHE {0}
  CONFIG.C_USE_MMU {0}
  CONFIG.C_USE_BRANCH_TARGET_CACHE {1}
  CONFIG.C_FREQ {25000000}
} $cpu

connect_bd_net [get_bd_pins clock_manager/mclk] [get_bd_pins cpu/Clk]

apply_bd_automation -rule xilinx.com:bd_rule:microblaze -config {
  axi_intc {1}
  axi_periph {Enabled}
  cache {None}
  clk {/clock_manager/mclk}
  debug_module {Debug Only}
  ecc {None}
  local_mem {128KB}
  preset {None}
} $cpu

set interrupt_concat [get_bd_cells cpu_xlconcat]
# Rename interrupt concat (must be done separately)
set_property name interrupt_concat $interrupt_concat

set_property -dict {
  CONFIG.NUM_PORTS 4
} $interrupt_concat

# USB UART
set uart [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uart16550:2.0 uart]
apply_board_connection -board_interface "usb_uart" -ip_intf ${uart}/UART -diagram $diagram_name

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Clk_master {/clock_manager/mclk}
  Clk_slave {Auto}
  Clk_xbar {Auto}
  Master {/cpu (Periph)}
  Slave {${uart}/S_AXI}
  master_apm {0}
} [get_bd_intf_pins ${uart}/S_AXI]

connect_bd_net [get_bd_pins ${uart}/ip2intc_irpt] [get_bd_pins ${interrupt_concat}/In1]

# MIDI UART
set midi_uart [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uart16550:2.0 midi_uart]

make_bd_pins_external -name midi_uart_rxd [get_bd_pins ${midi_uart}/sin]
make_bd_pins_external -name midi_uart_txd [get_bd_pins ${midi_uart}/sout]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Clk_master {/clock_manager/mclk}
  Clk_slave {Auto}
  Clk_xbar {Auto}
  Master {/cpu (Periph)}
  Slave {${midi_uart}/S_AXI}
  master_apm {0}
} [get_bd_intf_pins ${midi_uart}/S_AXI]

connect_bd_net [get_bd_pins ${midi_uart}/ip2intc_irpt] [get_bd_pins ${interrupt_concat}/In2]

# Debug UART
set debug_uart [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uart16550:2.0 debug_uart]

make_bd_pins_external -name debug_uart_rxd [get_bd_pins ${debug_uart}/sin]
make_bd_pins_external -name debug_uart_txd [get_bd_pins ${debug_uart}/sout]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Clk_master {/clock_manager/mclk}
  Clk_slave {Auto}
  Clk_xbar {Auto}
  Master {/cpu (Periph)}
  Slave {${debug_uart}/S_AXI}
  master_apm {0}
} [get_bd_intf_pins ${debug_uart}/S_AXI]

connect_bd_net [get_bd_pins ${debug_uart}/ip2intc_irpt] [get_bd_pins ${interrupt_concat}/In3]

# LED/Switch GPIO
set leds_switches [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 leds_switches]
set_property -dict {
  CONFIG.C_GPIO_WIDTH {16}
  CONFIG.C_GPIO2_WIDTH {16}
  CONFIG.C_IS_DUAL {1}
  CONFIG.C_ALL_INPUTS_2 {1}
  CONFIG.GPIO_BOARD_INTERFACE {led_16bits}
  CONFIG.GPIO2_BOARD_INTERFACE {dip_switches_16bits}
} $leds_switches

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Clk_master {/clock_manager/mclk}
  Clk_slave {Auto}
  Clk_xbar {Auto}
  Master {/cpu (Periph)}
  Slave {${leds_switches}/S_AXI}
  master_apm {0}
} [get_bd_intf_pins ${leds_switches}/S_AXI]

apply_bd_automation -rule xilinx.com:bd_rule:board -config {
  Board_Interface {led_16bits}
  Manual_Source {Auto}
} [get_bd_intf_pins ${leds_switches}/GPIO]

apply_bd_automation -rule xilinx.com:bd_rule:board -config {
  Board_Interface {dip_switches_16bits}
  Manual_Source {Auto}
} [get_bd_intf_pins ${leds_switches}/GPIO2]

# Timer
set timer [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 timer]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Clk_master {/clock_manager/mclk}
  Clk_slave {Auto}
  Clk_xbar {/clock_manager/mclk}
  Master {/cpu (Periph)}
  Slave {${timer}/S_AXI}
  master_apm {0}
} [get_bd_intf_pins ${timer}/S_AXI]

connect_bd_net [get_bd_pins ${timer}/interrupt] [get_bd_pins ${interrupt_concat}/In0]

# Strings
for {set i 0} {$i < 8} {incr i} {
  set string [create_bd_cell -type ip -vlnv benwolsieffer.com:magnet_zither:axi_string:1.0 string_$i]

  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
    Clk_master {/clock_manager/mclk}
    Clk_slave {Auto}
    Clk_xbar {Auto}
    Master {/cpu (Periph)}
    Slave {${string}/S_AXI}
    master_apm {0}
  }  [get_bd_intf_pins ${string}/S_AXI]
  
  make_bd_pins_external -name string_$i [get_bd_pins ${string}/output]
}

# Reset controller
apply_bd_automation -rule xilinx.com:bd_rule:board -config {
  Board_Interface {reset}
  Manual_Source {Auto}
} [get_bd_pins clock_manager/reset]

apply_bd_automation -rule xilinx.com:bd_rule:board -config {
  Board_Interface {reset}
  Manual_Source {New External Port (ACTIVE_LOW)}
} [get_bd_pins rst_clock_manager_25M/ext_reset_in]

regenerate_bd_layout
save_bd_design

make_wrapper -files [get_files $diagram_file] -top
add_files -norecurse ${diagram_dir}/${diagram_name}/hdl/${diagram_name}_wrapper.vhd
