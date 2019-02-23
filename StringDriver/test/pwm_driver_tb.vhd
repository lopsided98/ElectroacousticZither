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

entity pwm_driver_tb is
end pwm_driver_tb;

architecture testbench of pwm_driver_tb is
    constant clk_period: time := 1 us; -- 10 MHz master clock
    constant pwm_period: positive := 1000;
    signal clk: std_logic := '0';
    
    signal duty_cycle: unsigned(9 downto 0) := (others => '0');
    signal output: std_logic; -- PWM output

    component pwm_driver is
        generic(bits: natural;
                period: natural);
        port(clk: in std_logic;
             duty_cycle: in std_logic_vector(bits - 1 downto 0);
             output: out std_logic := '0');
    end component;
begin

    dut: pwm_driver
        generic map(bits => 10,
                    period => pwm_period)
        port map(clk => clk,
                 duty_cycle => std_logic_vector(duty_cycle),
                 output => output);

    process begin
        duty_cycle <= to_unsigned(0, duty_cycle'length);
        wait for 10 * pwm_period * clk_period;
        
        duty_cycle <= to_unsigned(100, duty_cycle'length);
        wait for 10 * pwm_period * clk_period;
        
        duty_cycle <= to_unsigned(300, duty_cycle'length);
        wait for 10 * pwm_period * clk_period;
        
        duty_cycle <= to_unsigned(500, duty_cycle'length);
        wait for 10 * pwm_period * clk_period;
        
        duty_cycle <= to_unsigned(750, duty_cycle'length);
        wait for 10 * pwm_period * clk_period;
        
        duty_cycle <= to_unsigned(1000, duty_cycle'length);
        wait for 10 * pwm_period * clk_period;
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
