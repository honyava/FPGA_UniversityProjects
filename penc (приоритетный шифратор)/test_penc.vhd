library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity test is
end test;

architecture tb of test is 
	constant CLK_FREQ : integer := 50e6;
	constant CLK_PERIOD : time := 1 sec / CLK_FREQ;
	constant N : integer := 2;
	
	signal input_tb    :  std_logic_vector (2**N - 1 downto 0) := (others => '0');
	signal r_tb        :  std_logic := '0'; 
	signal output_tb   :  std_logic_vector (N - 1 downto 0);

	signal test_output : std_logic_vector (N-1 downto 0) := (others => '0'); 
	
	signal zeros : std_logic_vector (2**N - 1 downto 0) := (others => '0'); 
	
	
begin	 
	
	penc : entity work.penc	
	generic map(		  
		N => N
		)
	port map(
		input  => input_tb,
		r      => r_tb,
		output => output_tb	 
		);
		
		
	sim : process
	variable int : integer;
	begin
		report "START";
		
		
		
		
		
		
		
		report "START ENABLE CHECK";
		
		r_tb <= '0';

		for i in 0 to 2**(2**N) - 1 loop	
			
			input_tb <= std_logic_vector(to_unsigned(i, input_tb'length));
			wait for 1 fs;
				
			if (input_tb /= zeros) then	 
				int := integer(floor(log2(real(to_integer(unsigned(input_tb))))));
				test_output <= std_logic_vector(to_unsigned(int, test_output'length));
			else
				test_output <= (others => 'Z');
			end if;
			
			wait for CLK_PERIOD/2;
		
			
			assert (test_output = output_tb)
			report "in: " & to_string(input_tb)
			& ";  out: " & to_string(output_tb) 
			& ";  must be: " & to_string(test_output) severity error;
			
		end loop; 
		
		report "STOP ENABLE CHECK";	 
		
		
		
		
		
		report "START DISABLE CHECK";
		
		r_tb <= '1'; 
		
		for i in 0 to 2**(2**N) - 1 loop	
			
			input_tb <= std_logic_vector(to_unsigned(i, input_tb'length));
			wait for 1 fs;
				
			test_output <= (others => 'Z');
			
			wait for CLK_PERIOD/2;
		
			
			assert (test_output = output_tb)
			report "in: " & to_string(input_tb)
			& ";  out: " & to_string(output_tb) 
			& ";  must be: " & to_string(test_output) severity error;
			
		end loop;
		
		report "STOP DISABLE CHECK";
		
		
		report "START Z CHECK";
		
		r_tb <= '0';

		input_tb <= (others => 'Z');
		wait for 1 fs;
			
		
		test_output <= (others => 'Z');
		wait for CLK_PERIOD/2;
	
		
		assert (test_output = output_tb)
		report "in: " & to_string(input_tb)
		& ";  out: " & to_string(output_tb) 
		& ";  must be: " & to_string(test_output) severity error;
			
		input_tb <= (others => '0');
		test_output <= (others => '0');
		
		report "STOP Z CHECK";
		
		
		
		report "STOP";
		
		
		std.env.finish;
		
	end process sim; 
	
	
end tb;

