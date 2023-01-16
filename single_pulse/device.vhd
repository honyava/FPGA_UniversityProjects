library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity imp is  
  port (  
    clk    : in  std_logic;
    trig   : in  std_logic := '0';
    cs   : in  std_logic_vector (1 downto 0) := "01";    --"01" falling edge, "10" - rising edge, "11" - any edge;
    output : out std_logic := '0'
    ); 
end entity imp;

architecture rtl of imp is
	signal output_temp :  std_logic := '0';
begin 	
	
	single_pulse : entity work.single_pulse	 	
	port map(
		clk => clk, 
		trig => output_temp,
		cs => cs,
 		output => output
		);
	
	drebezg : entity work.drebezg	
	port map(
		clk => clk, 
		trig => trig,
 		output => output_temp
		);
		
	
end architecture rtl;