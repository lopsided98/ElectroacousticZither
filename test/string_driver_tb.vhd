----------------------------------------------------------------------------------
-- Company: COCO 20, 19W
-- Engineer: Ben Wolsieffer
--
-- Create Date: 08/11/2018 10:06:13 PM
-- Design Name:
-- Module Name: pwm_driver_tb - behavior
-- Project Name: MagnetHarp
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
use IEEE.numeric_std.all;

entity string_driver_tb is
end string_driver_tb;

architecture testbench of string_driver_tb is
    constant clk_period: time := 50 ns; -- 20 MHz master clock
    constant amplitude_bits: positive := 10;
    constant period_bits: positive := 20;
    constant pwm_period: positive := 1000;
    signal clk: std_logic := '0';
    
    signal amplitude: natural := 0;
    signal period: positive := 10000;
    signal output: std_logic; -- PWM output

    component string_driver is
        generic(amplitude_bits: positive := 10;
                period_bits: positive := 16;
                pwm_period: positive := 1000);
        port(clk: in std_logic;
             amplitude: in std_logic_vector(amplitude_bits - 1 downto 0);
             period: in std_logic_vector(period_bits - 1 downto 0);
             output: out std_logic);
    end component;
begin

    dut: string_driver
        generic map(amplitude_bits => amplitude_bits,
                    period_bits => period_bits,
                    pwm_period => pwm_period)
        port map(clk => clk,
                 amplitude => std_logic_vector(to_unsigned(amplitude, amplitude_bits)),
                 period => std_logic_vector(to_unsigned(period, period_bits)),
                 output => output);

    process begin
        amplitude <= 1000;
        period <= 200000;
        wait for 10 * 200000 * clk_period;
        
        amplitude <= 200;
        period <= 50000;
        wait for 10 * 50000 * clk_period;
        
        amplitude <= 0;
        period <= 40000;
        wait for 10 * 40000 * clk_period;
        
        amplitude <= 700;
        period <= 100000;
        wait for 10 * 100000 * clk_period;
        
        amplitude <= 0;
        wait;
    end process;

    -- Clock process definitions
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;


end testbench;
