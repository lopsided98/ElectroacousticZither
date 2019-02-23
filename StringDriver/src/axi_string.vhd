----------------------------------------------------------------------------------
-- Company: COCO 20, 19W
-- Engineer: Ben Wolsieffer
-- 
-- Create Date: 02/21/2019 07:12:54 PM
-- Design Name: 
-- Module Name: axi_string - behavior
-- Project Name: 
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
use IEEE.math_real.all;

entity axi_string is
    generic(C_FAMILY: string := "virtex7";
            -- AXI Parameters
            C_S_AXI_ACLK_FREQ_HZ: natural := 25_000_000;
            C_S_AXI_DATA_WIDTH: natural := 32;
            C_S_AXI_ADDR_WIDTH: natural := 4;  
            -- String Parameters
            -- defines the PWM period (40 us / 25 kHz)
            max_amplitude: natural := 1000);
    port(-- Clock and Reset
         S_AXI_ACLK: in std_logic;
         S_AXI_ARESETN: in std_logic;
         -- Write Address Channel
         S_AXI_AWADDR: in std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
         S_AXI_AWVALID: in std_logic;
         S_AXI_AWREADY: out std_logic;
         -- Write Data Channel
         S_AXI_WDATA: in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
         S_AXI_WSTRB: in std_logic_vector((C_S_AXI_DATA_WIDTH / 8) - 1 downto 0);
         S_AXI_WVALID: in std_logic;
         S_AXI_WREADY: out std_logic;
         -- Read Address Channel
         S_AXI_ARADDR: in std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
         S_AXI_ARVALID: in std_logic;
         S_AXI_ARREADY: out std_logic;
         -- Read Data Channel
         S_AXI_RDATA: out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
         S_AXI_RRESP: out std_logic_vector(1 downto 0);
         S_AXI_RVALID: out std_logic;
         S_AXI_RREADY: in std_logic;
         -- Write Response Channel
         S_AXI_BRESP: out std_logic_vector(1 downto 0);
         S_AXI_BVALID: out std_logic;
         S_AXI_BREADY: in std_logic;
         output: out std_logic);
end axi_string;

architecture behavior of axi_string is

    type main_fsm_type is (reset, idle, read_transaction_in_progress, write_transaction_in_progress, complete);

    constant PERIOD_BITS: natural := C_S_AXI_DATA_WIDTH;
    constant AMPLITUDE_BITS: natural := natural(ceil(log2(real(max_amplitude + 1))));
    constant FLAGS_BITS: natural := 1;
    
    constant DEFAULT_PERIOD: std_logic_vector(PERIOD_BITS - 1 downto 0) := (others => '1');
    constant DEFAULT_AMPLITUDE: std_logic_vector(AMPLITUDE_BITS - 1 downto 0) := (others => '0');
    constant DEFAULT_FLAGS: std_logic_vector(FLAGS_BITS - 1 downto 0) := (others => '0');
    
    constant FLAGS_INVERT_BIT: integer := 0;

    -- Registers
    signal period_register_address_valid: std_logic;
    signal period_register: std_logic_vector(PERIOD_BITS - 1 downto 0) := DEFAULT_PERIOD;
    signal amplitude_register_address_valid: std_logic;
    signal amplitude_register: std_logic_vector(AMPLITUDE_BITS - 1 downto 0) := DEFAULT_AMPLITUDE;
    signal flags_register_address_valid: std_logic;
    signal flags_register: std_logic_vector(FLAGS_BITS - 1 downto 0) := DEFAULT_FLAGS;
    
    signal duty_cycle: std_logic_vector(AMPLITUDE_BITS - 1 downto 0);
    
    signal local_address: integer range 0 to 2**C_S_AXI_ADDR_WIDTH;
    signal local_address_valid: std_logic;

    signal combined_S_AXI_AWVALID_S_AXI_ARVALID: std_logic_vector(1 downto 0);
    signal local_reset: std_logic;
    signal current_state: main_fsm_type := idle;
    signal next_state: main_fsm_type;
    signal write_enable_registers: std_logic;
    signal send_read_data_to_AXI: std_logic;

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

    string_driver_comp: string_driver
        generic map(amplitude_bits => AMPLITUDE_BITS,
                    period_bits => PERIOD_BITS)
        port map(clk => S_AXI_ACLK,
                 amplitude => amplitude_register,
                 invert => flags_register(FLAGS_INVERT_BIT),
                 period => period_register,
                 output => duty_cycle);
                 
    pwm_driver_comp: pwm_driver
        generic map(bits => AMPLITUDE_BITS,
                    period => MAX_AMPLITUDE)
        port map(clk => S_AXI_ACLK,
                 duty_cycle => duty_cycle,
                 output => output);

    local_reset <= not S_AXI_ARESETN;
    combined_S_AXI_AWVALID_S_AXI_ARVALID <= S_AXI_AWVALID & S_AXI_ARVALID;

    state_machine_update: process(S_AXI_ACLK) begin
        if rising_edge(S_AXI_ACLK) then
            if local_reset = '1' then
                current_state <= reset;
            else
                current_state <= next_state;
            end if;
        end if;
    end process;
    
    state_machine_decisions: process(current_state, combined_S_AXI_AWVALID_S_AXI_ARVALID, S_AXI_ARVALID, S_AXI_RREADY, S_AXI_AWVALID, S_AXI_WVALID, S_AXI_BREADY, local_address, local_address_valid) begin
        S_AXI_ARREADY <= '0';
        S_AXI_RRESP <= "--";
        S_AXI_RVALID <= '0';
        S_AXI_WREADY <= '0';
        S_AXI_BRESP <= "--";
        S_AXI_BVALID <= '0';
        S_AXI_WREADY <= '0';
        S_AXI_AWREADY <= '0';
        write_enable_registers <= '0';
        send_read_data_to_AXI <= '0';
       
        case current_state is
            when reset =>
                next_state <= idle;
    
            when idle =>
                next_state <= idle;
                case combined_S_AXI_AWVALID_S_AXI_ARVALID is
                    when "01" => next_state <= read_transaction_in_progress;
                    when "10" => next_state <= write_transaction_in_progress;
                    when others => NULL;
                end case;
            
            when read_transaction_in_progress =>
                next_state <= read_transaction_in_progress;
                S_AXI_ARREADY <= S_AXI_ARVALID;
                S_AXI_RVALID <= '1';
                S_AXI_RRESP <= "00";
                send_read_data_to_AXI <= '1';
                if S_AXI_RREADY = '1' then
                    next_state <= complete;
                end if;

            when write_transaction_in_progress =>
                next_state <= write_transaction_in_progress;
                write_enable_registers <= '1';
                S_AXI_AWREADY <= S_AXI_AWVALID;
                S_AXI_WREADY <= S_AXI_WVALID;
                S_AXI_BRESP <= "00";
                S_AXI_BVALID <= '1';
                if S_AXI_BREADY = '1' then
                    next_state <= complete;
                end if;
    
            when complete => 
                case combined_S_AXI_AWVALID_S_AXI_ARVALID is
                    when "00" => next_state <= idle;
                    when others => next_state <= complete;
                end case;
            
            when others =>
                next_state <= reset;
        end case;
    end process;
    
    
    send_data_to_AXI_RDATA: process(local_address_valid, send_read_data_to_AXI, local_address, period_register, amplitude_register, flags_register) begin
        S_AXI_RDATA <= (others => '0');
        if (local_address_valid = '1' and send_read_data_to_AXI = '1') then
            case (local_address) is
                when 0 => 
                    S_AXI_RDATA(period_register'range) <= period_register;
                when 4 =>
                    S_AXI_RDATA(amplitude_register'range) <= amplitude_register;
                when 8 =>
                    S_AXI_RDATA(flags_register'range) <= flags_register;
                when others => NULL;
            end case;
        end if;
    end process;
    
    local_address_capture_register: process(S_AXI_ACLK) begin
       if rising_edge(S_AXI_ACLK) then
            if local_reset = '1' then
                local_address <= 0;
            else
                if local_address_valid = '1' then
                    case (combined_S_AXI_AWVALID_S_AXI_ARVALID) is
                        when "10" => local_address <= to_integer(unsigned(S_AXI_AWADDR(C_S_AXI_ADDR_WIDTH - 1 downto 0)));
                        when "01" => local_address <= to_integer(unsigned(S_AXI_ARADDR(C_S_AXI_ADDR_WIDTH - 1 downto 0)));
                        when others => local_address <= local_address;
                    end case;
                end if;
            end if;
       end if;
    end process;
    
    
    period_register_process: process(S_AXI_ACLK) begin
       if rising_edge(S_AXI_ACLK) then
            if local_reset = '1' then
                period_register <= DEFAULT_PERIOD;
            else
                if (period_register_address_valid = '1') then
                    period_register <= S_AXI_WDATA(period_register'range);
                end if;
            end if;
       end if;
    end process;
    
    
    amplitude_register_process: process(S_AXI_ACLK) begin
       if rising_edge(S_AXI_ACLK) then
            if local_reset = '1' then
                amplitude_register <= DEFAULT_AMPLITUDE;
            else
                if (amplitude_register_address_valid = '1') then
                    amplitude_register <= S_AXI_WDATA(amplitude_register'range);
                end if;
            end if;
       end if;
    end process;
    
    flags_register_process: process(S_AXI_ACLK) begin
       if rising_edge(S_AXI_ACLK) then
            if local_reset = '1' then
                flags_register <= DEFAULT_FLAGS;
            else
                if (flags_register_address_valid = '1') then
                    flags_register <= S_AXI_WDATA(flags_register'range);
                end if;
            end if;
       end if;
    end process;

    address_range_analysis: process(local_address, write_enable_registers) begin
        period_register_address_valid <= '0';
        amplitude_register_address_valid <= '0';
        flags_register_address_valid <= '0';
        local_address_valid <= '1';
        
        if write_enable_registers = '1' then
            case (local_address) is
                when 0 => period_register_address_valid <= '1';
                when 4 => amplitude_register_address_valid <= '1';
                when 8 => flags_register_address_valid <= '1';
                when others => local_address_valid <= '0';
        end case;
    end if;
end process;

end behavior;
