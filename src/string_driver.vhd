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
    generic(amplitude_bits: natural;
            period_bits: natural);
    port(clk: in std_logic;
         amplitude: in std_logic_vector(amplitude_bits - 1 downto 0);
         period: in std_logic_vector(period_bits - 1 downto 0);
         output: out std_logic_vector(amplitude_bits - 1 downto 0));
end string_driver;

architecture behavior of string_driver is

    signal half_period: std_logic_vector(period_bits - 2 downto 0);
    signal toggle: std_logic;
    signal binary_output: std_logic;

    component down_counter is
        generic(bits: natural := 4);
        port(clk: in std_logic;
             k: in std_logic_vector(bits - 1 downto 0); -- preset value
             CE: in std_logic := '1'; -- count enable
             preset: in std_logic := '0'; -- assert to set the counter to k
             y: out std_logic_vector(bits - 1 downto 0); -- counter output
             TC: out std_logic); -- terminal count
    end component;

begin

    half_period_counter: down_counter
        generic map(period_bits - 1)
        port map(clk => clk,
                 k => half_period,
                 TC => toggle);

    half_period <= period(period_bits - 1 downto 1);

    process(clk) begin
        if rising_edge(clk) then
            if toggle = '1' then
                if binary_output = '0' then
                    binary_output <= '1';
                else
                    binary_output <= '0';
                end if;
            end if;
        end if;
    end process;
    
    output <= amplitude when binary_output = '1' else (others => '0');

end behavior;
