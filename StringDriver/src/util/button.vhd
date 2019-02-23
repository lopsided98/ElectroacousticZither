----------------------------------------------------------------------------------
-- Company: ENGS 31, 18X
-- Engineer: Ben Wolsieffer
--
-- Create Date: 08/12/2018 10:21:29 PM
-- Design Name:
-- Module Name: button - behavior
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: Button synchronizer and debouncer
--
-- Dependencies: sync.vhd, down_counter.vhd
--
-- Revision:
-- Revision 0.01 - File Created
-- Revision 0.02 - Remove monopulser
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.math_real.all;
use IEEE.numeric_std.all;

entity button is
    generic(count: positive := 10000);
    port(clk: in std_logic;
         input: in std_logic;
         output: buffer std_logic);
end button;

architecture behavior of button is
    constant DEBOUNCE_BITS: positive := integer(ceil(log2(real(count + 1))));

    component sync is
        port(clk: in std_logic;
             input: in std_logic;
             output: out std_logic);
    end component;

    component down_counter is
        generic(bits: positive := 4);
        port (clk: in std_logic;
              k: in std_logic_vector(bits - 1 downto 0); -- preset value
              CE: in std_logic := '1'; -- count enable
              preset: in std_logic := '0'; -- assert to set the counter to k
              y: out std_logic_vector(bits - 1 downto 0); -- counter output
              TC: out std_logic); -- terminal count
    end component;

    -- synchronization
    signal sync_out: std_logic;

    -- debouncing
    signal debounce_output: std_logic := '0';
    signal not_changing: std_logic;
    signal change_trigger: std_logic;

    -- monopulsing
    signal mp_reg: std_logic_vector(1 downto 0) := "00";
begin

   -- synchronization
    sync_map: sync
        port map(clk => clk,
                 input => input,
                 output => sync_out);

    -- debouncing
    not_changing <= '1' when sync_out = output else '0';
    debounce_counter: down_counter
        generic map(bits => DEBOUNCE_BITS)
        port map(clk => clk,
                 k => std_logic_vector(to_unsigned(count, DEBOUNCE_BITS)),
                 preset => not_changing,
                 TC => change_trigger);

    process(clk) begin
        if rising_edge(clk) then
            if change_trigger = '1' then
                output <= sync_out;
            end if;
        end if;
    end process;

end behavior;
