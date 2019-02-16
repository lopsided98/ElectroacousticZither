----------------------------------------------------------------------------------
-- Company: COCO 20, 19W
-- Engineer: Ben Wolsieffer
-- 
-- Create Date: 02/15/2019 06:23:55 PM
-- Design Name: 
-- Module Name: button_controller - behavior
-- Project Name: MagnetHarp
-- Target Devices: Basys 3
-- Tool Versions: 
-- Description: State machine for controlling a string with buttons
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity button_controller is
    generic(amplitude_bits: natural;
            attack_amplitude: positive;
            sustain_amplitude: positive;
            attack_time: positive);
    port(clk: in std_logic;
         button: in std_logic;
         amplitude: out std_logic_vector(amplitude_bits - 1 downto 0);
         invert: out std_logic);
end button_controller;

architecture behavior of button_controller is
    constant ATTACK_TIME_BITS: natural := natural(ceil(log2(real(attack_time + 1))));

    component down_counter is
        generic(bits: natural := 4);
        port (clk: in std_logic;
              k: in std_logic_vector(bits - 1 downto 0); -- preset value
              CE: in std_logic := '1'; -- count enable
              preset: in std_logic := '0'; -- assert to set the counter to k
              y: out std_logic_vector(bits - 1 downto 0); -- counter output
              TC: out std_logic); -- terminal count
    end component;

    type state_type is (st_idle, st_attack, st_sustain);
    
    signal state: state_type := st_idle;
    signal next_state: state_type;
    
    signal attack_counter_preset: std_logic;
    signal attack_done: std_logic;
begin

    attack_counter: down_counter
        generic map(bits => ATTACK_TIME_BITS)
        port map(clk => clk,
                 k => std_logic_vector(to_unsigned(attack_time, ATTACK_TIME_BITS)),
                 preset => attack_counter_preset,
                 TC => attack_done);
    
    next_state_proc: process(state, button, attack_done) begin
        next_state <= state;
    
        case state is
            when st_idle =>
                if button = '1' then
                    next_state <= st_attack;
                end if;
            when st_attack =>
                if button = '0' then
                    next_state <= st_idle;
                elsif attack_done = '1' then
                    next_state <= st_sustain;
                end if;
            when st_sustain =>
                if button = '0' then
                    next_state <= st_idle;
                end if;
        end case;
    end process;
    
    output_proc: process(state) begin    
        amplitude <= (others => '0');
        invert <= '0';
        attack_counter_preset <= '1';

        case state is
            when st_idle => null;
            when st_attack =>
                amplitude <= std_logic_vector(to_unsigned(attack_amplitude, amplitude_bits));
                attack_counter_preset <= '0';
            when st_sustain =>
                amplitude <= std_logic_vector(to_unsigned(sustain_amplitude, amplitude_bits));
        end case;
    end process;
    
    state_update_proc: process(clk) begin
        if rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

end behavior;
