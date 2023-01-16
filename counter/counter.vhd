library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
	generic (
		N: natural := 4
		);
	port(
		clk : in STD_LOGIC;
		ewr : in STD_LOGIC;	 -- разрешение параллельной записи
		ect : in STD_LOGIC;	 -- разрешение счета
		x : in STD_LOGIC_VECTOR(N-1 downto 0); 
		y : out STD_LOGIC_VECTOR(N-1 downto 0) := (others => '0')
		);
end counter;



architecture rtl of counter is
begin
	
	process (clk)
		variable cnt: integer := 0;
	begin
		if rising_edge(clk) and ewr = '1' then 
			y <= x;
			cnt := to_integer(unsigned(x));
		elsif rising_edge(clk) and ewr = '0' and ect = '1' then
			cnt := cnt+1;
			y <= std_logic_vector(to_unsigned(cnt, y'length));
		end if;
		
	end process;
	
end rtl;
