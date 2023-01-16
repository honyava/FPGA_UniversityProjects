library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;	


use work.tools.all;	 
use work.converters.all;


entity test_log2 is
end entity test_log2;

architecture rtl of test_log2 is  
	signal N : integer := 8;
	signal x : std_logic_vector(N-1 downto 0);
	signal y : std_logic_vector(log2(N)-1 downto 0);
begin
	
	sim : process
	variable i : integer := 0;
	variable j : integer := 0;
	variable pos : integer := 0;
	begin	
		for i in 0 to 2**N-1 loop  
			x <= to_stdlogicvector(i, x'length); 
			for j in 0 to x'length-1 loop
				if (x(j) = '1') then
					pos := j;
				end if;
			end loop;
			y <= to_stdlogicvector(pos, y'length);
			wait for 100 ns;
		end loop;
		std.env.finish;
	end process sim;
								   
end architecture rtl;
