library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; 

use work.converters.all;

entity lifo_tb is
end entity;

architecture test of lifo_tb is
    constant CLK_FREQ : integer := 50e6;
    constant CLK_PERIOD : time := 1 sec/ CLK_FREQ;
    
    constant depth_tb : natural := 8;
    constant width_tb : natural := 8;
    
    signal clk_tb : std_logic := '0';
    
    signal ce_tb : std_logic := '0';
    signal clr_tb : std_logic := '0';
    signal rd_tb :std_logic := '0'; 
    signal wr_tb :std_logic := '1';
    
    signal data_tb : std_logic_vector(7 downto 0) := (others => '0');
    signal q_tb : std_logic_vector(7 downto 0);
begin 
    lifo: entity work.lifo
    generic map(
        DEPTH => depth_tb,
        WIDTH => width_tb
        )
    port map (
        CE => ce_tb,
        CLR => clr_tb,
        CLK => clk_tb,
        RD => rd_tb,
        WR => wr_tb,
        DATA => data_tb,
        Q => q_tb
        );
    
    clk_tb <= not clk_tb after CLK_PERIOD/2;
    
    sim : process	
    begin 
		
		--clr_tb <= '1';
--		wait for 1 ns ;
--		clr_tb <= '0';
--		
--		ce_tb <= '1';
--        wait for 3*CLK_PERIOD/4;
--        
--        
--        DATA_tb <= "10101010";
--		wait for CLK_PERIOD;
--		
--        DATA_tb <= "01010101";
--		wait for CLK_PERIOD; 
--		
--        DATA_tb <= "10000001";
--		wait for CLK_PERIOD;
--		
--        DATA_tb <= "11111111";
--		wait for CLK_PERIOD;
--		
--        DATA_tb <= "00000000";
--		wait for CLK_PERIOD;
--		
--        DATA_tb <= "11010011";	
--		wait for 3*CLK_PERIOD/4 - 1 ns; 
--		
--		rd_tb <= '1';
--		
--		
--		
--		
--        wait for 20*CLK_PERIOD; 
--		
--		clr_tb <= '1';
--		
--		wait for 8*CLK_PERIOD + 1 ns; 
--		
		
		
		
		
        ce_tb <= '1';
        wait for CLK_PERIOD/3;
        wr_tb <= '1';
        
        for i in 1 to DEPTH_tb loop 
            DATA_tb <= to_slv(i, DATA_tb'length);
            wait until rising_edge(clk_tb);
            wait for 16 ns;
        end loop;
        rd_tb <= '1';
		DATA_tb <= (others => '0');
		
		
		wr_tb <= '0'; 
		wait for 17*CLK_PERIOD / 2 - 16 ns;
		
		clr_tb <= '1'; 
		
		wait for 9*CLK_PERIOD;
		
		clr_tb <= '0'; 
		
		wait for 9*CLK_PERIOD;
		
        --DATA_tb <= "11000011";
--        wait until rising_edge(clk_tb);
--        wait for 16 ns;
--        for i in 1 to DEPTH_tb loop 
--            DATA_tb <= not DATA_tb;
--            wait until rising_edge(clk_tb);
--            wait for 16 ns;
--        end loop;
--        wr_tb <= '0';
--        for i in 1 to DEPTH_tb loop 
--            DATA_tb <= not DATA_tb;
--            wait until rising_edge(clk_tb);
--            wait for 16 ns;
--        end loop;
        std.env.finish;
    end process;
    
end test;