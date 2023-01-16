library IEEE;
use IEEE.std_logic_1164.all;

entity andN is
	generic (
		N : natural := 8
		);	
	port(
		x : in STD_LOGIC_VECTOR(N-1 downto 0);
		y : out STD_LOGIC		
		);
end andN;

architecture rtl of andN is
begin
	y <= and x;	
end rtl;
