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

entity button_controller_tb is
end button_controller_tb;

architecture testbench of button_controller_tb is
    constant CLK_PERIOD: time := 40 ns; -- 25 MHz
    constant AMPLITUDE_BITS: positive := 10;
    constant ATTACK_AMPLITUDE: positive := 1000;
    constant SUSTAIN_AMPLITUDE: positive := 417;
    constant ATTACK_TIME: positive := 500000; -- 20 ms
    
    signal clk: std_logic := '0';
    
    signal button: std_logic := '0';
    signal amplitude: std_logic_vector(AMPLITUDE_BITS - 1 downto 0);
    signal invert: std_logic;

    component button_controller is
        generic(amplitude_bits: natural;
                attack_amplitude: positive;
                sustain_amplitude: positive;
                attack_time: positive);
        port(clk: in std_logic;
             button: in std_logic;
             amplitude: out std_logic_vector(amplitude_bits - 1 downto 0);
             invert: out std_logic);
    end component;
begin

    dut: button_controller
        generic map(amplitude_bits => AMPLITUDE_BITS,
                    attack_amplitude => ATTACK_AMPLITUDE,
                    sustain_amplitude => SUSTAIN_AMPLITUDE,
                    attack_time => ATTACK_TIME)
        port map(clk => clk,
                 button => button,
                 amplitude => amplitude,
                 invert => invert);

    process begin
        button <= '1';
        wait for 4 * ATTACK_TIME * CLK_PERIOD;
        button <= '0';
        wait for 2 * ATTACK_TIME * CLK_PERIOD;
        
        button <= '1';
        wait for (ATTACK_TIME / 2) * CLK_PERIOD;
        button <= '0';
        wait for 2 * ATTACK_TIME * CLK_PERIOD;
        wait;
    end process;

    -- Clock process definitions
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;


end testbench;
