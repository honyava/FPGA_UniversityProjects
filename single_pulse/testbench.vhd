library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;	

 
entity imp_tb is  
end entity imp_tb;

architecture tb of imp_tb is 
	constant CLK_FREQ : integer := 50e6;
	constant CLK_PERIOD : time := 1 sec / CLK_FREQ;
	constant N : integer := 8;
	
	signal clk_tb : std_logic := '0'; 
	signal cs_tb  : std_logic_vector (1 downto 0):= "01";  
	signal trig_tb : std_logic := '0';
	signal output_tb : std_logic := '0';	
	
begin	 
	
	clk_tb <= not clk_tb after CLK_PERIOD / 2;
	
	imp : entity work.imp	
	port map(
		clk => clk_tb, 
		trig => trig_tb,
		cs => cs_tb,
 		output => output_tb
		);
	
	sim : process
	variable i : integer := 0;
	begin
		report "START" severity warning;
		
		
		wait for CLK_PERIOD / 2; 
	
		
		for i in 0 to 30 loop
			trig_tb <= not trig_tb;
			wait for CLK_PERIOD / 100; 
		end loop;
		
		wait for CLK_PERIOD * 5;
		
		trig_tb <= '0';
		
		wait until rising_edge(clk_tb);
		
		wait for CLK_PERIOD / 4;
		
		assert (output_tb = '1')
			report "Error #1 cs = " & to_string(cs_tb)
			& ";  output: " & to_string(output_tb) 
			& ";  must be: 0" severity error;	
			
			
			
			
			
			
			
		wait for CLK_PERIOD * 7; 
		
		cs_tb <= "10";
		
		for i in 0 to 30 loop
			trig_tb <= not trig_tb;
			wait for CLK_PERIOD / 100; 
		end loop;
		
		wait until rising_edge(clk_tb);
		
		wait for CLK_PERIOD / 4;
		
		assert (output_tb = '1')
			report "Error #2 cs = " & to_string(cs_tb)
			& ";  output: " & to_string(output_tb) 
			& ";  must be: 0" severity error;
			
		wait for CLK_PERIOD * 5;
		trig_tb <= '0';
			
			
			
			
			
			
			
		wait for CLK_PERIOD * 7; 
		
		cs_tb <= "11";
		
		for i in 0 to 30 loop
			trig_tb <= not trig_tb;
			wait for CLK_PERIOD / 100; 
		end loop;
		
		wait until rising_edge(clk_tb);
		
		wait for CLK_PERIOD / 4;
		
		assert (output_tb = '1')
			report "Error #3.1 cs = " & to_string(cs_tb)
			& ";  output: " & to_string(output_tb) 
			& ";  must be: 0" severity error;
			
		wait for CLK_PERIOD * 5;
		trig_tb <= '0';			  
		
		
		
		wait until rising_edge(clk_tb);
		
		wait for CLK_PERIOD / 4;
		
		assert (output_tb = '1')
			report "Error #3.2 cs = " & to_string(cs_tb)
			& ";  output: " & to_string(output_tb) 
			& ";  must be: 0" severity error;  
			
			
			
			
		wait for CLK_PERIOD * 5;
		
		
		
		
		
		
		
		
		
		
		
		
		
			
			
			
			
			
			
			
			
			
		
		
		report "STOP" severity warning;

		
		std.env.finish;
		
	end process sim;

end architecture tb;