----------------------------------------------------------------------------------
-- Company: COCO 20, 19W
-- Engineer: Ben Wolsieffer
-- 
-- Create Date: 02/11/2019 01:04:11 PM
-- Design Name: 
-- Module Name: pwm_driver - behavior
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

entity pwm_driver is
    generic(bits: natural;
            period: natural);
    port(clk: in std_logic;
         duty_cycle: in std_logic_vector(bits - 1 downto 0);
         output: out std_logic := '0');
end pwm_driver;

architecture behavior of pwm_driver is
    signal pos: std_logic_vector(bits - 1 downto 0) := (others => '0');

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

    counter: down_counter
        generic map(bits)
        port map(clk => clk,
                 k => std_logic_vector(to_unsigned(period, bits)),
                 y => pos);

    process(clk) begin
        if rising_edge(clk) then
            if unsigned(pos) >= unsigned(duty_cycle) then
                output <= '0';
            else 
                output <= '1';
            end if;
        end if;
    end process;

end behavior;
