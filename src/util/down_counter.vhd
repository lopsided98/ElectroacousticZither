----------------------------------------------------------------------------------
-- Company: ENGS 31, 18X
-- Engineer: Ben Wolsieffer
--
-- Create Date: 07/23/2018 10:04:40 PM
-- Design Name:
-- Module Name: down_counter - behavior
-- Project Name: down_counter
-- Target Devices: Artix 7 - Basys 3
-- Tool Versions:
-- Description: A generic counter implementation that only counts down.
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

entity down_counter is
    generic(bits: positive := 4);
    port (clk: in std_logic;
          k: in std_logic_vector(bits - 1 downto 0); -- preset value
          CE: in std_logic := '1'; -- count enable
          preset: in std_logic := '0'; -- assert to set the counter to k
          y: out std_logic_vector(bits - 1 downto 0); -- counter output
          TC: out std_logic); -- terminal count
end down_counter;

architecture behavior of down_counter is
    signal uy: unsigned(y'range) := (others => '0');
begin
    y <= std_logic_vector(uy);

    TC <= '1' when uy = 0 else '0';

    process(clk) begin
        if rising_edge(clk) then
            if preset = '1' then
                uy <= unsigned(k);
            elsif CE = '1' then
                -- wrap around to k
                if uy = 0 then
                    uy <= unsigned(k);
                else
                    uy <= uy - 1;
                end if;
            end if;
        end if;
    end process;
end behavior;
