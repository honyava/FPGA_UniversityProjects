library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity fifo_lifo_tb is
end entity;

architecture test of fifo_lifo_tb is
    constant CLK_FREQ : integer := 50e6;
    constant CLK_PERIOD : time := 1 sec/ CLK_FREQ;
    
    constant depth_tb : natural := 16;
    constant width_tb : natural := 8;
    
    signal clk_tb : std_logic := '0';
    
    signal ce_tb : std_logic := '0';
    signal clr_tb : std_logic := '0';
    signal rd_tb :std_logic := '0'; 
    signal wr_tb :std_logic := '1';
    
    signal data_tb : std_logic_vector(7 downto 0) := (others => '0');
    signal q_tb : std_logic_vector(7 downto 0) := (others => '0');
begin 
    fifo: entity work.fifo
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
    wr_tb <= '1';
    
    sim : process	
    begin
        ce_tb <= '1';
        wait for 3*CLK_PERIOD/4;
        
        
        DATA_tb <= "10101010";
		wait for CLK_PERIOD;
		
        DATA_tb <= "01010101";
		wait for CLK_PERIOD; 
		
        DATA_tb <= "10000001";
		wait for CLK_PERIOD;
		
        DATA_tb <= "11111111";
		wait for CLK_PERIOD;
		
        DATA_tb <= "00000000";
		wait for CLK_PERIOD;
		
        DATA_tb <= "11010011";	
		wait for 3*CLK_PERIOD/4 - 1 ns; 
		
		rd_tb <= '1';
		
		
		
		
        wait for 8*CLK_PERIOD; 
		
		clr_tb <= '1';
		
		wait for 8*CLK_PERIOD + 1 ns; 
		
        std.env.finish;
    end process;
    
end test;