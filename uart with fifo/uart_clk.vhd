library ieee;
use ieee.std_logic_1164.all;

entity uart_clk is
    generic (
        CLK_FREQ  : positive := 50e6;
        BAUD_RATE : positive := 115200;
        OS_RATE   : positive := 16
        );
    port (
        clk   : in std_logic;
        reset : in std_logic;
        
        os_tick   : out std_logic := '0';
        baud_tick : out std_logic := '0'
        );
end entity uart_clk;

architecture rtl of uart_clk is 
    constant BAUD_DIV : positive := CLK_FREQ / BAUD_RATE;
    constant OS_DIV   : positive := CLK_FREQ / (BAUD_RATE * OS_RATE);
begin
    
    process (clk, reset) is
        variable count_baud : natural range 0 to BAUD_DIV - 1 := 0;
    begin
        if reset then
            baud_tick  <= '0';
            count_baud := 0;
        elsif rising_edge(clk) then
            if count_baud = BAUD_DIV - 1 then
                count_baud := 0;
                baud_tick  <= '1';
            else
                count_baud := count_baud + 1;
                baud_tick  <= '0';
            end if;
        end if;
    end process;
    
    process (clk, reset) is
        variable count_os : natural range 0 to OS_DIV - 1 := 0;
    begin
        if reset then
            os_tick  <= '0';
            count_os := 0;
        elsif rising_edge(clk) then
            if count_os = OS_DIV - 1 then
                count_os := 0;
                os_tick  <= '1';
            else
                count_os := count_os + 1;
                os_tick  <= '0';
            end if;
        end if;
    end process;
    
end architecture rtl;
