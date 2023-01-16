library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity single_port_ram_tb is
end single_port_ram_tb;

architecture sim of single_port_ram_tb is
    
    constant clk_hz : integer := 50e6;
    constant clk_period : time := 1 sec / clk_hz;
    
    constant DATA_WIDTH_tb : natural := 16;
    constant ADDR_WIDTH_tb : natural := 10;
    
    signal clk_tb : std_logic := '1';
    signal rst_tb : std_logic := '1';
    
    signal addr_tb : natural range 0 to 2**ADDR_WIDTH_tb - 1;
    signal data_tb : std_logic_vector((DATA_WIDTH_tb-1) downto 0);
    signal we_tb   : std_logic := '1';
    signal q_tb    : std_logic_vector((DATA_WIDTH_tb -1) downto 0);
    
begin
    
    clk_tb <= not clk_tb after clk_period / 2;
    
    DUT : entity work.single_port_ram(rtl)
    generic map(
        DATA_WIDTH => DATA_WIDTH_tb,
        ADDR_WIDTH => ADDR_WIDTH_tb
        )
    
    port map 
        (
        clk    => clk_tb,
        addr   => addr_tb,
        data   => data_tb,
        we     => we_tb,
        q      => q_tb
        );
    
    SEQUENCER_PROC : process
    begin
        report "Test start"
        severity warning;
        
        we_tb <= '1';
        
        for i in 0 to 2**ADDR_WIDTH_tb - 1 loop
            wait until rising_edge(clk_tb);
            wait for 5 ns; 
            addr_tb <= i;
            data_tb <= std_logic_vector(to_unsigned(i, 16));
            assert q_tb = data_tb
            report "out: " & to_string(to_integer(unsigned(q_tb)))
            & " should be: " & to_string(to_integer(unsigned(data_tb)))
            severity error;
        end loop;
        
        for i in 0 to 2**ADDR_WIDTH_tb - 1 loop 
            if i = 20 then
                we_tb <= '0';
            end if;
            
            wait until rising_edge(clk_tb);
            wait for 5 ns; 
            addr_tb <= i;
            data_tb <= std_logic_vector(to_unsigned(i*5, 16));
            
            
            if i >= 20 then
                assert q_tb = std_logic_vector(to_unsigned(i-1, 16))
                report "out: " & to_string(to_integer(unsigned(q_tb)))
                & " should be: " & to_string(i-1)
                severity error; 
            else
                assert q_tb = data_tb
                report "out: " & to_string(to_integer(unsigned(q_tb)))
                & " should be: " & to_string(to_integer(unsigned(data_tb)))
                severity error;
            end if;
        end loop;
        
        we_tb <= '0';
        wait for clk_period * 2;
        
        report "Test complete"
        severity warning;
        
        finish;
    end process;
    
end architecture;