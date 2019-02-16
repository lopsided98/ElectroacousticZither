----------------------------------------------------------------------------------
-- Company: ENGS 31, 18X
-- Engineer: Ben Wolsieffer
--
-- Create Date: 08/12/2018 10:21:29 PM
-- Design Name:
-- Module Name: sync - behavior
-- Project Name: VoiceRecorder
-- Target Devices:
-- Tool Versions:
-- Description: Dual flop synchronizer
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
use IEEE.math_real.all;
use IEEE.numeric_std.all;

entity sync is
    port(clk: in std_logic;
         input: in std_logic;
         output: out std_logic);
end sync;

architecture behavior of sync is
    signal sync_1: std_logic := '0';
    signal sync_2: std_logic := '0';
begin

   -- synchronization
    sync_proc: process(clk) begin
        if rising_edge(clk) then
            sync_1 <= input;
            sync_2 <= sync_1;
        end if;
    end process;
    
    output <= sync_2;

end behavior;
