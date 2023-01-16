library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity t1_atmega16_tb is
end t1_atmega16_tb;

architecture sim of t1_atmega16_tb is

    constant clk_hz : integer := 100e6;
    constant clk_period : time := 1 sec / clk_hz;
    
    constant N : natural := 8;

    signal clk_tb    : std_logic := '1';
    -- signal updown_tb : std_logic := '1';
    -- signal top_tb    : std_logic_vector(2 downto 0) := "000";
    
    signal OVF1_tb    : std_logic;
    signal t1_capt_tb : std_logic;

    signal WGM_tb   : std_logic_vector(1 downto 0) := (others => '0');
    signal COM_tb   : std_logic_vector(1 downto 0) := (others => '0');
    signal OC1_tb   : std_logic := '0';
    signal OCR1_tb  : std_logic_vector(N-1 downto 0) := (others => '0');
    
    signal ext_capt_tb   : std_logic := '0';
    signal acomp_capt_tb : std_logic := '0';
    signal ACIC_tb       : std_logic := '1';
    
    signal icr1_tb  : std_logic_vector(N-1 downto 0);
    signal tcnt1_tb : std_logic_vector(N-1 downto 0);

begin

    clk_tb <= not clk_tb after clk_period / 2;

    DUT : entity work.t1_atmega16(rtl)
    generic map (
        N => N
    )
    port map (
        clk    => clk_tb,
        
        ICP1 => ext_capt_tb,
        ACO  => acomp_capt_tb,
        ACIC => ACIC_tb,
        
        WGM  => WGM_tb,
        COM  => COM_tb,
        OC1  => OC1_tb,
        OCR1 => OCR1_tb,

        OVF1   => OVF1_tb,
        t1_capt => t1_capt_tb,
        
        ICR1  => icr1_tb,
        tcnt1 => tcnt1_tb         
    );

    SEQUENCER_PROC : process
    begin
        -- Checking capture
        for i in 0 to 4 loop            
            
            for i in 0 to 2**N + 10 loop
                wait for clk_period;
            end loop;
            
            for i in 0 to 1 loop
                ACIC_tb <= not ACIC_tb;
                
                ext_capt_tb <= '1';
                acomp_capt_tb <= '0';
                wait for clk_period*10;
                
                ext_capt_tb <= '0';
                acomp_capt_tb <= '1';
                wait for clk_period*10; 
            end loop;
            
        end loop; 
        
        -- Setting OCR1
        OCR1_tb <= std_logic_vector(to_unsigned(125, N));
        
        -- Checking compare modes
        for i in 0 to 3 loop
            for j in 0 to 3 loop
                WGM_tb <= std_logic_vector(to_unsigned(i, 2));
                COM_tb <= std_logic_vector(to_unsigned(j, 2));
                wait until rising_edge(clk_tb);

                wait for clk_period * 2 * (2**N + 10);
                if WGM_tb = "01" then
                    wait for clk_period * 2 * (2**N + 10);
                end if;                
            end loop;
        end loop;
        
        finish;
    end process;

end architecture;