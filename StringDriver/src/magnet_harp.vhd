----------------------------------------------------------------------------------
-- Company: COCO 20, 19W
-- Engineer: Ben Wolsieffer
-- 
-- Create Date: 02/9/2019 12:14:03 AM
-- Design Name: 
-- Module Name: magnet_harp - behavior
-- Project Name: MagnetHarp
-- Target Devices: Basys 3
-- Tool Versions: 
-- Description: Top level file for the magnet harp
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity magnet_harp is
    port(mclk: in std_logic;
         btns: in std_logic_vector(7 downto 0);
         strings: out std_logic_vector(7 downto 0);
         leds: out std_logic_vector(15 downto 0));
end magnet_harp;

architecture behavior of magnet_harp is
    constant CLK_DIVIDER: natural := 4; -- 25 MHz main clock

    signal clk: std_logic;

    component clock_divider is
        generic(divider: natural);
        port(mclk: in std_logic;
             dclk: out std_logic);
    end component;
    
    component button_string is
        generic(period: natural);
        port(clk: in std_logic;
             button_raw: in std_logic;
             output: out std_logic);
    end component;
begin

    main_clock_divider: clock_divider
        generic map(divider => CLK_DIVIDER)
        port map(mclk => mclk,
                 dclk => clk);
    
    string_1: button_string
        generic map(period => 191117) -- C3, 130.8099 Hz
        port map(clk => clk,
                 button_raw => btns(0),
                 output => strings(0));

    string_2: button_string
        generic map(period => 127551) -- G3, 196.0000 Hz
        port map(clk => clk,
                 button_raw => btns(1),
                 output => strings(1));

    string_3: button_string
        generic map(period => 85132) -- D4, 293.6616 Hz
        port map(clk => clk,
                 button_raw => btns(2),
                 output => strings(2));

    string_4: button_string
        generic map(period => 56818) -- A4, 440.0014 Hz
        port map(clk => clk,
                 button_raw => btns(3),
                 output => strings(3));
 
    string_5: button_string
        generic map(period => 56818) -- 440.0014 Hz
        port map(clk => clk,
                 button_raw => btns(4),
                 output => strings(4));

    string_6: button_string
        generic map(period => 56818) -- 440.0014 Hz
        port map(clk => clk,
                 button_raw => btns(5),
                 output => strings(5));

    string_7: button_string
        generic map(period => 56818) -- 440.0014 Hz
        port map(clk => clk,
                 button_raw => btns(6),
                 output => strings(6));

    string_8: button_string
        generic map(period => 56818) -- 440.0014 Hz
        port map(clk => clk,
                 button_raw => btns(7),
                 output => strings(7));

end behavior;