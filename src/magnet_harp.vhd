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
         btn_c: in std_logic;
         btn_u: in std_logic;
         btn_l: in std_logic;
         btn_r: in std_logic;
         btn_d: in std_logic;
         strings: out std_logic_vector(7 downto 0));
end magnet_harp;

architecture behavior of magnet_harp is
    constant CLK_DIVIDER: natural := 4; -- 25 MHz main clock

    signal clk: std_logic;

    component clock_divider is
        generic(divider: natural);
        port(mclk: in std_logic;
             dclk: out std_logic);
    end component;
begin

    main_clock_divider: clock_divider
        generic map(divider => CLK_DIVIDER)
        port map(mclk => mclk,
                 dclk => clk);

end behavior;