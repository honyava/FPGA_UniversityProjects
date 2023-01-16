library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity drebezg is  
	
	port (	
		clk    : in  std_logic := '0';
		trig   : in  std_logic := '0';
		output : out std_logic := '0'
		); 
end entity drebezg;

architecture rtl1 of drebezg is	
	signal out_temp :  std_logic := '0';
begin
	process (clk, trig)
	variable count : integer := 0; 
	variable a : integer := 0;
	begin 	
		
		if (rising_edge(clk)) then
			count := count + 1;	
		end if;
		
		if(rising_edge(trig)) then
			output <= '1';
			a := count; 
		end if;	
		
		if(trig = '0' and (count - a >= 1)) then	 
			output <= '0';
		end if;	
		
		
--		if(rising_edge(clk)) then
--			out_temp <= trig;
--			output <= (not out_temp and trig);
--		end if;
	end process;
end architecture rtl1;
