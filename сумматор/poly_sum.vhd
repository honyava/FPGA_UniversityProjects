library IEEE;
use IEEE.std_logic_1164.all;

entity poly_sum is
	port(
		a : in STD_LOGIC;
		b : in STD_LOGIC;
		
		s : out std_logic;
		p : out std_logic
		);
end poly_sum;

architecture rtl of poly_sum is
begin
	
	s <= a xor b;
	p <= a and b;
	
end rtl;