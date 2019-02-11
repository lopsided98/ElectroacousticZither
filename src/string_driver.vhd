----------------------------------------------------------------------------------
-- Company: COCO 20, 19W
-- Engineer: Ben Wolsieffer
-- 
-- Create Date: 02/11/2019 01:04:11 PM
-- Design Name: 
-- Module Name: string_driver - behavior
-- Project Name: MagnetHarp
-- Target Devices: Basys 3
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
use IEEE.math_real.all;

entity string_driver is
    generic(amplitude_bits: positive := 10;
            period_bits: positive := 16;
            pwm_period: positive := 1000);
    port(clk: in std_logic;
         amplitude: in std_logic_vector(amplitude_bits - 1 downto 0);
         period: in std_logic_vector(period_bits - 1 downto 0);
         output: out std_logic);
end string_driver;

architecture behavior of string_driver is

    signal half_period: std_logic_vector(period_bits - 2 downto 0);
    signal wave_output: std_logic_vector(amplitude'range) := (others => '0');
    signal toggle: std_logic;

    component down_counter is
        generic(bits: positive := 4);
        port(clk: in std_logic;
             k: in std_logic_vector(bits - 1 downto 0); -- preset value
             CE: in std_logic := '1'; -- count enable
             preset: in std_logic := '0'; -- assert to set the counter to k
             y: out std_logic_vector(bits - 1 downto 0); -- counter output
             TC: out std_logic); -- terminal count
    end component;
    
    component pwm_driver is
        generic(bits: positive := 16;
                period: positive);
        port(clk: in std_logic;
             duty_cycle: in std_logic_vector(bits - 1 downto 0);
             output: out std_logic := '0');
    end component;
begin

    half_period_counter: down_counter
        generic map(period_bits - 1)
        port map(clk => clk,
                 k => half_period,
                 TC => toggle);
    
    pwm: pwm_driver
        generic map(bits => amplitude_bits,
                    period => pwm_period)
        port map(clk => clk,
                 duty_cycle => wave_output,
                 output => output);

    half_period <= period(period_bits - 1 downto 1);

    process(clk) begin
        if rising_edge(clk) then
            if toggle = '1' then
                if wave_output = (wave_output'range => '0') then
                    wave_output <= amplitude;
                else
                    wave_output <= (others => '0');
                end if;
            end if;
        end if;
    end process;

end behavior;
