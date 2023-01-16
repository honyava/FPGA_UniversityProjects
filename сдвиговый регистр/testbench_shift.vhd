library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test is
end test;

architecture tb of test is 
	constant CLK_FREQ : integer := 50e6;
	constant CLK_PERIOD : time := 1 sec / CLK_FREQ;
	constant N : integer := 8;
	
	signal clk_tb : std_logic := '0'; 
	signal q_tb  : std_logic_vector (N-1 downto 0):= (others => '0');  
	signal d_tb : std_logic := '0';
	signal r_tb : std_logic := '0';
	
	signal test_output : std_logic_vector (N-1 downto 0) := (others => '0');  
	
	
begin	 
	
	clk_tb <= not clk_tb after CLK_PERIOD/2;
	
	shiftN : entity work.shiftN	
	generic map(		  
		N => 8
		)
	port map(
		clk => clk_tb, 
		q => q_tb,
		d =>d_tb,
		r => r_tb	 
		);
	
	
	
	sim : process
	begin
		report "START";	 
		
		
		
		report "START DISABLE CHECK";
		
		r_tb <= '1';
		
		d_tb <= not d_tb;
		wait for CLK_PERIOD/2;
		
		test_output <= (others => 'Z');
		
		assert (test_output = q_tb)
		report "in: " & to_string(d_tb)
		& ";  out: " & to_string(q_tb) 
		& ";  must be: " & to_string(test_output) severity error;
		wait for CLK_PERIOD/2; 
		
		report "STOP DISABLE CHECK"; 
		
		
		
		
		report "START ENABLE CHECK";
		
		r_tb <= '0';
		d_tb <= '0';
		wait for CLK_PERIOD/2;
		
		for i in 0 to N-1 loop
			d_tb <= not d_tb;
			test_output <= test_output(test_output'high - 1 downto test_output'low) & d_tb;
			wait for CLK_PERIOD/2;
			assert (test_output = q_tb)
			report "in: " & to_string(d_tb)
			& ";  out: " & to_string(q_tb) 
			& ";  must be: " & to_string(test_output) severity error;
			wait for CLK_PERIOD/2;
			
		end loop;
		
		report "END ENABLE CHECK";
		
		test_output <= test_output(test_output'high - 1 downto test_output'low) & d_tb;
		wait for CLK_PERIOD/2;
		
		
		report "START Z CHECK";	
		d_tb <= 'Z';
		wait for CLK_PERIOD/2;
		test_output <= test_output(test_output'high - 1 downto test_output'low) & d_tb;
		
		wait for CLK_PERIOD/2;
		
		assert (test_output = q_tb)
		report "in: " & to_string(d_tb)
		& ";  out: " & to_string(q_tb) 
		& ";  must be: " & to_string(test_output) severity error;
		
		report "STOP Z CHECK"; 
		
		
		
		
		report "STOP";
		
		std.env.finish;
		
	end process sim; 
	
	
end tb;

