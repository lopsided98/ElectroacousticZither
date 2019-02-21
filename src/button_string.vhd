----------------------------------------------------------------------------------
-- Company: COCO 20, 19W
-- Engineer: Ben Wolsieffer
-- 
-- Create Date: 02/15/2019 10:09:08 PM
-- Design Name: 
-- Module Name: button_string - behavior
-- Project Name: MagnetHarp
-- Target Devices: Basys 3
-- Tool Versions: 
-- Description: Wrapper for button controlled string
-- 
-- Dependencies: util/button.vhd, button_controller.vhd, string_driver.vhd, pwm_driver.vhd 
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

entity button_string is
    generic(period: natural);
    port(clk: in std_logic;
         button_raw: in std_logic;
         output: out std_logic);
end button_string;

architecture behavior of button_string is
    -- 25 MHz clock
    
    constant DEBOUNCE_TIME: positive := 75000; -- 3 ms

    constant MAX_AMPLITUDE: natural := 1000; -- defines the PWM period (40 us / 25 kHz)
    constant AMPLITUDE_BITS: natural := natural(ceil(log2(real(MAX_AMPLITUDE + 1))));

    constant ATTACK_AMPLITUDE: natural := 1000; -- 12V
    constant SUSTAIN_AMPLITUDE: natural := 417; -- 5V
    constant RELEASE_AMPLITUDE: natural := 1000; -- 12V
    constant ATTACK_TIME: positive := 500000; -- 20 ms
    constant RELEASE_TIME: positive := 250000; -- 10 ms

    
    constant PERIOD_BITS: natural := natural(ceil(log2(real(period + 1))));
    
    constant PWM_PERIOD: natural := 1;

    signal button_debounce: std_logic;
    signal amplitude: std_logic_vector(AMPLITUDE_BITS - 1 downto 0);
    signal invert: std_logic;
    signal duty_cycle: std_logic_vector(AMPLITUDE_BITS - 1 downto 0);

    component button is
        generic(count: positive := 10000);
        port(clk: in std_logic;
             input: in std_logic;
             output: buffer std_logic);
    end component;
    
    component button_controller is
        generic(amplitude_bits: natural;
                attack_amplitude: positive;
                sustain_amplitude: positive;
                release_amplitude: positive;
                attack_time: positive;
                release_time: positive);
        port(clk: in std_logic;
             button: in std_logic;
             amplitude: out std_logic_vector(amplitude_bits - 1 downto 0);
             invert: out std_logic);
    end component;
    
    component string_driver is
    generic(amplitude_bits: natural;
            period_bits: natural);
    port(clk: in std_logic;
         amplitude: in std_logic_vector(amplitude_bits - 1 downto 0);
         period: in std_logic_vector(period_bits - 1 downto 0);
         invert: in std_logic;
         output: out std_logic_vector(amplitude_bits - 1 downto 0));
    end component;
    
    component pwm_driver is
        generic(bits: natural;
                period: natural);
        port(clk: in std_logic;
             duty_cycle: in std_logic_vector(bits - 1 downto 0);
             output: out std_logic := '0');
    end component;
begin

    button_comp: button
        generic map(count => DEBOUNCE_TIME)
        port map(clk => clk,
                 input => button_raw,
                 output => button_debounce);
    
    button_controller_comp: button_controller
        generic map(amplitude_bits => AMPLITUDE_BITS,
                    attack_amplitude => ATTACK_AMPLITUDE,
                    sustain_amplitude => SUSTAIN_AMPLITUDE,
                    release_amplitude => RELEASE_AMPLITUDE,
                    attack_time => ATTACK_TIME,
                    release_time => RELEASE_TIME)
        port map(clk => clk,
                 button => button_debounce,
                 amplitude => amplitude,
                 invert => invert);
                 
    string_driver_comp: string_driver
        generic map(amplitude_bits => AMPLITUDE_BITS,
                    period_bits => PERIOD_BITS)
        port map(clk => clk,
                 amplitude => amplitude,
                 invert => invert,
                 period => std_logic_vector(to_unsigned(period, PERIOD_BITS)),
                 output => duty_cycle);
                 
    pwm_driver_comp: pwm_driver
        generic map(bits => AMPLITUDE_BITS,
                    period => MAX_AMPLITUDE)
        port map(clk => clk,
                 duty_cycle => duty_cycle,
                 output => output);

end behavior;
