# Constraint file for the magnet harp

# Clock signal
# Bank = 34, Pin name = CLK, Sch name = CLK100MHZ
set_property PACKAGE_PIN W5 [get_ports mclk]							
set_property IOSTANDARD LVCMOS33 [get_ports mclk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports mclk]


# LEDs
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports {leds[0]}]
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS33} [get_ports {leds[1]}]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports {leds[2]}]
set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports {leds[3]}]
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports {leds[4]}]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports {leds[5]}]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {leds[6]}]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports {leds[7]}]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports {leds[8]}]
set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33} [get_ports {leds[9]}]
set_property -dict {PACKAGE_PIN W3 IOSTANDARD LVCMOS33} [get_ports {leds[10]}]
set_property -dict {PACKAGE_PIN U3 IOSTANDARD LVCMOS33} [get_ports {leds[11]}]
set_property -dict {PACKAGE_PIN P3 IOSTANDARD LVCMOS33} [get_ports {leds[12]}]
set_property -dict {PACKAGE_PIN N3 IOSTANDARD LVCMOS33} [get_ports {leds[13]}]
set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports {leds[14]}]
set_property -dict {PACKAGE_PIN L1 IOSTANDARD LVCMOS33} [get_ports {leds[15]}]

# Buttons
# Bank = 14, Pin name = , Sch name = BTNC
#set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports btn_c]
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
set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS33} [get_ports {strings[0]}]
# Sch name = JA2
set_property -dict {PACKAGE_PIN L2 IOSTANDARD LVCMOS33} [get_ports {strings[1]}]
# Sch name = JA3
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {strings[2]}]
# Sch name = JA4
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {strings[3]}]
# Sch name = JA7
set_property -dict {PACKAGE_PIN H1 IOSTANDARD LVCMOS33} [get_ports {strings[4]}]
# Sch name = JA8
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {strings[5]}]
# Sch name = JA9
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {strings[6]}]
# Sch name = JA10
set_property -dict {PACKAGE_PIN G3 IOSTANDARD LVCMOS33} [get_ports {strings[7]}]

# Pmod Header JB
# Sch name = JB1
set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports {btns[0]}]
# Sch name = JB2
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports {btns[1]}]
# Sch name = JB3
set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33} [get_ports {btns[2]}]
# Sch name = JB4
set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports {btns[3]}]

# Pmod Header JC
# Sch name = JC1
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports {btns[4]}]
# Sch name = JC2
set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports {btns[5]}]
# Sch name = JC3
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports {btns[6]}]
# Sch name = JC4
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports {btns[7]}]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
