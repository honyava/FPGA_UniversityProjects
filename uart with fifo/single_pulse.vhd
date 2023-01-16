library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity single_pulse is
    port (
        clk  : in std_logic;
        sig  : in std_logic;
        slct : in std_logic_vector(1 downto 0);
        pls  : out std_logic
        );
end single_pulse;

architecture rtl of single_pulse is
    constant CLK_FREQ : integer := 1e6;
    constant btn_wait : integer := CLK_FREQ/100;
    
    signal int_sig : std_logic_vector(1 downto 0);
    
    signal flag_rise  : std_logic := '0';
    signal flag_fall  : std_logic := '0';
    
begin
    
    -- Trigger for posedge/negedge detector
    FLIP_FLOP : process(clk)  
    begin
        if rising_edge(clk) then
            int_sig <= int_sig(0) & sig;
        end if;
    end process;
    
    -- posedge
    flag_rise <= (not int_sig(1)) and int_sig(0)    ;
    -- negedge
    flag_fall <= (not int_sig(0)) and int_sig(1);     
    
    SIG_GEN : process(clk)
    begin
        if rising_edge(clk) then
            case slct is
                when "00" =>
                    if flag_rise = '1' then
                        pls <= '1';
                    else
                        pls <= '0';
                end if;
                when "01" =>
                    if flag_fall = '1' then
                        pls <= '1';
                    else
                        pls <= '0';
                end if;
                when "10" =>
                    if flag_rise = '1' or flag_fall = '1' then
                        pls <= '1';
                    else
                        pls <= '0';
                end if;
                when others =>
                pls <= '0';
            end case;
            
        end if;
    end process;
    
end architecture;