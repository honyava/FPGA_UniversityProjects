library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;	


use work.converters.all;


entity test_log2 is  
end entity test_log2;


architecture rtl of test_log2 is
	signal answer1 :  std_logic_vector(4 downto 0) := (others => '0'); 
	signal answer2 :  std_logic_vector(4 downto 0) := (others => '0'); 

	signal in1 : std_logic_vector(4 downto 0) := "10110";
	signal in2 : std_logic_vector(4 downto 0) := "11101";
	
	
	
begin
	
	answer1 <= to_grey_code(in1);  
	answer2 <= to_bin_code(in2);
	
	
	
	sim : process
	variable N : integer := 16;
	variable count : integer := 0;
	variable i : integer := 0;
	variable test_input : std_logic_vector(N-1 downto 0) := (others => '0');
	begin
		report "START" severity warning;	 
		
		for i in 0 to ((2 ** test_input'length) - 1) loop 
			
			test_input := std_logic_vector(to_signed(i, test_input'length));
			
			if (test_input /= to_bin_code(to_grey_code(test_input))) then
				count := count + 1;
			end if;
			
			assert (test_input = to_bin_code(to_grey_code(test_input)))
			report "in: " & to_string(test_input)
			& ";  out: " & to_string(to_bin_code(to_grey_code(test_input))) 
			& ";  must be: " & to_string(test_input) severity error;
			
			wait for 1 ps;
		end loop;
		
		report "STOP: Find " & to_string(count) & " errors" severity warning;
		
		std.env.finish;
		
	end process sim;

end architecture rtl;
