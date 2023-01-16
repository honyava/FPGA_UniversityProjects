library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity single_pulse is  
  port (  
    clk    : in  std_logic;
    trig   : in  std_logic := '0';
    cs   : in  std_logic_vector (1 downto 0) := "01";    --"01" falling edge, "10" - rising edge, "11" - any edge;
    output : out std_logic := '0'
    ); 
end entity single_pulse;

architecture rtl2 of single_pulse is
	signal out_temp :  std_logic := '0';
begin
	
	pulse: process (clk)  
		begin
		  if(rising_edge(clk)) then
		    out_temp <= trig;
		  case cs is
		    when "01" => output <=  (out_temp and not trig);
		    when "10" => output <=  (not out_temp and trig);
		    when "11" => output <=  out_temp xor trig;
		    when others => output <= 'Z';
		  end case;
		  end if;
	end process pulse; 
	
end architecture rtl2;