library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity Ethernet_tb is
end Ethernet_tb;

architecture sim of Ethernet_tb is

    constant clk_hz : integer := 50e6;
    constant clk_period : time := 1 sec / clk_hz;

    signal clk_tb : std_logic := '1';

    signal LCD_EN_tb       : std_logic;
    signal LCD_RS_tb       : std_logic;
    signal LCD_RW_tb       : std_logic;
    signal LCD_DATA_tb     : std_logic_vector(7 downto 0);
    signal LCD_ON_tb       : std_logic;
    signal LCD_BLON_tb     : std_logic;
    
    signal ENET_RD_N_tb    : std_logic := '1';
    signal ENET_WR_N_tb    : std_logic := '1';
    signal ENET_CS_N_tb    : std_logic;
    signal ENET_CMD_tb     : std_logic;
    signal ENET_INT_tb     : std_logic := '0';
    signal ENET_RESET_N_tb : std_logic := '1';
    signal ENET_CLK_tb     : std_logic;
    signal ENET_DATA_tb    : std_logic_vector(15 downto 0);
    

begin

    clk_tb <= not clk_tb after clk_period / 2;

    DUT : entity work.Ethernet(rtl)
    port map (
        clk => clk_tb,
        
        LCD_EN       => LCD_EN_tb,
        LCD_RS       => LCD_RS_tb,
        LCD_RW       => LCD_RW_tb,
        LCD_DATA     => LCD_DATA_tb,
        LCD_ON       => LCD_ON_tb,
        LCD_BLON     => LCD_BLON_tb,
        
        ENET_RD_N    => ENET_RD_N_tb,
        ENET_WR_N    => ENET_WR_N_tb,
        ENET_CS_N    => ENET_CS_N_tb,
        ENET_CMD     => ENET_CMD_tb,
        ENET_INT     => ENET_INT_tb,
        ENET_RESET_N => ENET_RESET_N_tb,
        ENET_CLK     => ENET_CLK_tb,
        ENET_DATA    => ENET_DATA_tb
        
    );

    SEQUENCER_PROC : process
    begin

        -- Check reset sequence

        wait for 20 ms;
        
        -- Check RX and TX sequence
        
        ENET_INT_tb <= '1';
        wait until rising_edge(clk_tb); 
        wait for 1 ms; 
        
        ENET_INT_tb <= '0';
        wait until rising_edge(clk_tb); 
        wait for 40 ms;
        
        finish;
    end process;

end architecture;