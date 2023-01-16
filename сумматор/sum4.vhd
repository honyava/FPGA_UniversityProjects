library IEEE;
use IEEE.std_logic_1164.all;

entity sum4 is
	port(
		a : in STD_LOGIC_vector (3 downto 0);
		b : in STD_LOGIC_vector (3 downto 0); 
		
		s : out std_logic_vector (3 downto 0);
		p : out std_logic		
	);
end sum4;

architecture rtl of sum4 is	  
	signal p1_out : std_logic; 
	signal p2_out : std_logic;
	signal p3_out : std_logic;
	
	component sum1 is	
		port(
			a : in STD_LOGIC;
			b : in STD_LOGIC; 
			p_in : in STD_LOGIC;  
			
			s : out std_logic;
			p_out : out std_logic		
			);
	end component;
	
begin
	
	sum11: sum1 
	port map (
		a => a(0),	 
		b => b(0),
		s => s(0),
		p_in => '0',
		p_out => p1_out
		);
	
	sum12: sum1
	port map (
		a => a(1),	 
		b => b(1),
		s => s(1),
		p_in => p1_out,
		p_out => p2_out
		);
		
	sum13: sum1 
	port map (
		a => a(2),	 
		b => b(2),
		s => s(2),
		p_in => p2_out,
		p_out => p3_out
		);
	
	sum14: sum1 
	port map (
		a => a(3),	 
		b => b(3),
		s => s(3),
		p_in => p3_out,
		p_out => p
		);
	
end rtl;