# Constraint file for the magnet zither

# Clock signal
# Bank = 34, Pin name = CLK, Sch name = CLK100MHZ
set sys_clock [get_ports sys_clock]	
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} $sys_clock
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} $sys_clock

# Switches
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports {dip_switches_16bits_tri_i[0]}]					
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {dip_switches_16bits_tri_i[1]}]					
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports {dip_switches_16bits_tri_i[2]}]					
set_property -dict {PACKAGE_PIN W17 IOSTANDARD LVCMOS33} [get_ports {dip_switches_16bits_tri_i[3]}]					
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33} [get_ports {dip_switches_16bits_tri_i[4]}]					
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {dip_switches_16bits_tri_i[5]}]					
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports {dip_switches_16bits_tri_i[6]}]					
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {dip_switches_16bits_tri_i[7]}]					
set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVCMOS33} [get_ports {dip_switches_16bits_tri_i[8]}]					
set_property -dict {PACKAGE_PIN T3 IOSTANDARD LVCMOS33} [get_ports {dip_switches_16bits_tri_i[9]}]					
set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports {dip_switches_16bits_tri_i[10]}]					
set_property -dict {PACKAGE_PIN R3 IOSTANDARD LVCMOS33} [get_ports {dip_switches_16bits_tri_i[11]}]					
set_property -dict {PACKAGE_PIN W2 IOSTANDARD LVCMOS33} [get_ports {dip_switches_16bits_tri_i[12]}]					
set_property -dict {PACKAGE_PIN U1 IOSTANDARD LVCMOS33} [get_ports {dip_switches_16bits_tri_i[13]}]					
set_property -dict {PACKAGE_PIN T1 IOSTANDARD LVCMOS33} [get_ports {dip_switches_16bits_tri_i[14]}]					
set_property -dict {PACKAGE_PIN R2 IOSTANDARD LVCMOS33} [get_ports {dip_switches_16bits_tri_i[15]}]					

# LEDs
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports {led_16bits_tri_o[0]}]
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS33} [get_ports {led_16bits_tri_o[1]}]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports {led_16bits_tri_o[2]}]
set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports {led_16bits_tri_o[3]}]
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports {led_16bits_tri_o[4]}]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports {led_16bits_tri_o[5]}]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {led_16bits_tri_o[6]}]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports {led_16bits_tri_o[7]}]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports {led_16bits_tri_o[8]}]
set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33} [get_ports {led_16bits_tri_o[9]}]
set_property -dict {PACKAGE_PIN W3 IOSTANDARD LVCMOS33} [get_ports {led_16bits_tri_o[10]}]
set_property -dict {PACKAGE_PIN U3 IOSTANDARD LVCMOS33} [get_ports {led_16bits_tri_o[11]}]
set_property -dict {PACKAGE_PIN P3 IOSTANDARD LVCMOS33} [get_ports {led_16bits_tri_o[12]}]
set_property -dict {PACKAGE_PIN N3 IOSTANDARD LVCMOS33} [get_ports {led_16bits_tri_o[13]}]
set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports {led_16bits_tri_o[14]}]
set_property -dict {PACKAGE_PIN L1 IOSTANDARD LVCMOS33} [get_ports {led_16bits_tri_o[15]}]

# Buttons
# Bank = 14, Pin name = , Sch name = BTNC
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports reset]
# Bank = 14, Pin name = , Sch name = BTNU
#set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports btn_u]
# Bank = 14, Pin name = , Sch name = BTNL
#set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33} [get_ports btn_l]
# Bank = 14, Pin name = , Sch name = BTNR
#set_property -dict {PACKAGE_PIN T17 IOSTANDARD LVCMOS33} [get_ports btn_r]
# Bank = 14, Pin name = , Sch name = BTND
#set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports btn_d]

# Pmod Header JA
# Sch name = JA1
set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS33} [get_ports {string_0}]
# Sch name = JA2
set_property -dict {PACKAGE_PIN L2 IOSTANDARD LVCMOS33} [get_ports {string_1}]
# Sch name = JA3
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {string_2}]
# Sch name = JA4
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {string_3}]
# Sch name = JA7
set_property -dict {PACKAGE_PIN H1 IOSTANDARD LVCMOS33} [get_ports {string_4}]
# Sch name = JA8
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {string_5}]
# Sch name = JA9
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {string_6}]
# Sch name = JA10
set_property -dict {PACKAGE_PIN G3 IOSTANDARD LVCMOS33} [get_ports {string_7}]

# Pmod Header JB
# Sch name = JB1
set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports midi_uart_rxd]
# Sch name = JB2
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports midi_uart_txd]
# Sch name = JB3
#set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33} [get_ports {btns[2]}]
# Sch name = JB4
#set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports {btns[3]}]

# Pmod Header JC
# Sch name = JC1
#set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports {btns[4]}]
# Sch name = JC2
#set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports {btns[5]}]
# Sch name = JC3
#set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports {btns[6]}]
# Sch name = JC4
#set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports {btns[7]}]

set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVCMOS33} [get_ports usb_uart_rxd]
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports usb_uart_txd]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
