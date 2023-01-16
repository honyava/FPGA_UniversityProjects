library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;	


use work.tools.all;


entity test_log2 is  
end entity test_log2;

architecture rtl of test_log2 is
signal answer1 : std_logic_vector (3 downto 0) := (others => '0');
signal answer2 : std_logic_vector (7 downto 0) := (others => '0');
signal answer3 : std_logic_vector (11 downto 0) := (others => '0');
signal answer4 : std_logic_vector (15 downto 0) := (others => '0');

signal answer5 : integer := 0;
signal answer6 : integer := 0;
signal answer7 : integer := 0;
signal answer8 : integer := 0;

signal in1 : integer := 1;	
signal in2 : integer := 12;
signal in3 : integer := 123;
signal in4 : integer := 1234;  

signal in5 : std_logic_vector (3 downto 0) := "0001"; --1 
signal in6 : std_logic_vector (7 downto 0) := "00100011"; --23 
signal in7 : std_logic_vector (11 downto 0) := "010001010110"; --456 
signal in8 : std_logic_vector (15 downto 0) := "0111100010010000"; --7890 


signal i : integer := 0;




begin	
	
	answer1 <= dec_to_bindec(in1);
	answer2 <= dec_to_bindec(in2);
	answer3 <= dec_to_bindec(in3);
	answer4 <= dec_to_bindec(in4);
	
	answer5 <= bindec_to_dec(in5);
	answer6 <= bindec_to_dec(in6);
	answer7 <= bindec_to_dec(in7);
	answer8 <= bindec_to_dec(in8);
	
	
	sim : process
	variable count : integer := 0;
	begin
		report "START" severity warning;	 
		
		for i in 0 to (10**3) loop
			
			if (i /= bindec_to_dec(dec_to_bindec(i))) then
				count := count + 1;
			end if;
			
			assert (i = bindec_to_dec(dec_to_bindec(i)))
			report "in: " & to_string(i)
			& ";  out: " & to_string(bindec_to_dec(dec_to_bindec(i))) 
			& ";  must be: " & to_string(i) severity error;
			
			wait for 1 ps;
		end loop;
		
		report "STOP: Find " & to_string(count) & " errors" severity warning;
		
		std.env.finish;
		
	end process sim;
	
end architecture rtl;
