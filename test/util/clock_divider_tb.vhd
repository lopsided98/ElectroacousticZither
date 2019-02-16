----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 08/11/2018 10:06:13 PM
-- Design Name:
-- Module Name: clock_divider_tb - behavior
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
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

entity clock_divider_tb is
end clock_divider_tb;

architecture testbench of clock_divider_tb is
    constant mclk_period : time := 1 us; -- 1 MHz master clock
    signal mclk: std_logic := '0';
    signal dclk: std_logic; -- divided clock output

    component clock_divider is
        generic(divider: integer);
        port(mclk: in std_logic;
             dclk: out std_logic);
    end component;
begin

    dut: clock_divider
        generic map(6)
        port map(mclk => mclk,
                 dclk => dclk);

    -- Clock process definitions
    clk_process: process
    begin
        mclk <= '0';
        wait for mclk_period / 2;
        mclk <= '1';
        wait for mclk_period / 2;
    end process;


end testbench;
