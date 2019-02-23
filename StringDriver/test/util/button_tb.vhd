----------------------------------------------------------------------------------
-- Company: ENGS 31, 18X
-- Engineer: Ben Wolsieffer
--
-- Create Date: 08/12/2018 10:49:35 PM
-- Design Name:
-- Module Name: button_tb - testbench
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies: button.vhd
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity button_tb is
end button_tb;

architecture testbench of button_tb is
    constant CLK_PERIOD: time := 10 ns; -- 100 MHz clock
    signal clk: std_logic := '0';

    component button is
        generic(count: positive := 1000);
        port(clk: in std_logic;
             input: in std_logic;
             output: out std_logic);
    end component;

    signal input: std_logic := '0';
    signal output: std_logic;
begin

    dut: button
        generic map(count => 10)
        port map(clk => clk,
                 input => input,
                 output => output);

    process begin
        -- Solidly press button
        wait for 5 * CLK_PERIOD;
        input <= '1';
        wait for 15 * CLK_PERIOD;

        -- release button
        input <= '0';
        wait for 15 * CLK_PERIOD;

        -- bouncy press
        input <= '1';
        wait for 3 * CLK_PERIOD;
        input <= '0';
        wait for 2 * CLK_PERIOD;
        input <= '1';
        wait for 4 * CLK_PERIOD;
        input <= '0';
        wait for CLK_PERIOD;
        input <= '1';

        wait;
    end process;

    -- Clock process definition
    clk_process: process begin
        clk <= '1';
        wait for CLK_PERIOD / 2;
        clk <= '0';
        wait for CLK_PERIOD / 2;
    end process;


end testbench;
