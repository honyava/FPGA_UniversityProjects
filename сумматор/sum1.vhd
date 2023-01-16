library IEEE;
use IEEE.std_logic_1164.all;

entity sum1 is
	port(
		a : in STD_LOGIC;
		b : in STD_LOGIC; 
		p_in : in STD_LOGIC;  
		
		s : out std_logic;
		p_out : out std_logic		
		);
end sum1;

architecture rtl of sum1 is	  
	signal s1_out : std_logic; 
	signal p1_out : std_logic; 
	signal p2_out : std_logic;
	
	component poly_sum is	
		port(
			a : in STD_LOGIC;
			b : in STD_LOGIC;
			
			s : out std_logic;
			p : out std_logic
			);
	end component;
	
begin
	
	poly_sum1: poly_sum 
	port map (
		a => a,	 
		b => b,
		s => s1_out,
		p => p1_out
		);
	
	poly_sum2: poly_sum 
	port map (
		a => p_in,	 
		b => s1_out,
		s => s,
		p => p2_out
		);
	
	p_out <= p2_out or p1_out;
	
end rtl;