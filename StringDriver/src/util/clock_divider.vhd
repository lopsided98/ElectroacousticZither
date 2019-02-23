----------------------------------------------------------------------------------
-- Company: ENGS 31, 18X
-- Engineer: Ben Wolsieffer
--
-- Create Date: 08/11/2018 08:38:05 PM
-- Design Name:
-- Module Name: clock_divider - behavior
-- Project Name:
-- Target Devices: Artix 7 - Basys 3
-- Tool Versions:
-- Description:
--
-- Dependencies: down_counter.vhd
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

library UNISIM;
use UNISIM.VComponents.all;

entity clock_divider is
    generic(divider: integer);
    port(mclk: in std_logic;
         dclk: out std_logic);
end clock_divider;

architecture behavior of clock_divider is

    constant COUNTER_VALUE: integer := divider / 2 - 1;
    constant COUNTER_BITS: integer := integer(ceil(log2(real(COUNTER_VALUE + 1))));
    signal dclk_unbuf: std_logic := '0'; -- unbuffered clock
    signal dclk_toggle: std_logic;

    component down_counter is
        generic(bits: positive := 4);
        port (clk: in std_logic;
              k: in std_logic_vector(bits - 1 downto 0); -- preset value
              CE: in std_logic := '1'; -- count enable
              preset: in std_logic := '0'; -- assert to set the counter to k
              y: out std_logic_vector(bits - 1 downto 0); -- counter output
              TC: out std_logic); -- terminal count
    end component;
begin

    assert (COUNTER_VALUE + 1) * 2 = divider report "Divider must be a multiple of two";

    counter: down_counter
        generic map(COUNTER_BITS)
        port map(clk => mclk,
                 k => std_logic_vector(to_unsigned(COUNTER_VALUE, COUNTER_BITS)),
                 TC => dclk_toggle);

    process(mclk) begin
        if rising_edge(mclk) then
            if dclk_toggle = '1' then
                dclk_unbuf <= not(dclk_unbuf);
            end if;
        end if;
    end process;

    -- The BUFG component puts the signal onto the FPGA clocking network
    dclk_buffer: BUFG
        port map(I => dclk_unbuf,
                 O => dclk);
end behavior;
