library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;	


use work.converters.all;


entity test_tools is  
end entity test_tools;

architecture rtl of test_tools is
signal in1 : std_logic_vector (3 downto 0) := "1001";  					--slv to int 	
signal out1 : integer := 0;	

signal in2 : std_logic := '1';  										--sl to int    
signal out2 : integer := 0;	

signal in3 : boolean := TRUE;  											--bool to sl  
signal out3 : std_logic := '0';	

signal in4 : integer := 31;  											--int to slv   
signal out4 : std_logic_vector (4 downto 0) := (others => '0');  

signal in5 : character := '7';  										--char to slv 
signal out5 : std_logic_vector (3 downto 0) := (others => '0');  


begin	
	out1 <= to_integer(in1);
	out2 <= to_integer(in2);
	out3 <= to_std_logic(in3);
	out4 <= to_stdlogicvector(in4, 5); 
	out5 <= to_stdlogicvector(in5);	
	
	
	sim : process
	variable N : integer := 8;
	variable i : integer := 0; 
	variable test_char : character := '0';
	variable test_input : std_logic_vector(N-1 downto 0) := (others => '0'); 
	variable test_sl : std_logic := '1';  
	begin
		report "START" severity warning;	
	
		
		for i in 0 to ((2 ** N) - 1) loop 
			
			assert (i = to_integer(to_stdlogicvector(i, N)))
			report "in: " & to_string(i)
			& ";  out: " & to_string(to_integer(to_stdlogicvector(i, N))) 
			& ";  must be: " & to_string(i) severity error;
			wait for 1 ps;
		end loop;
		
		report "slv to int, int to slv check completed" severity warning;	 
		
		
		
		test_sl := '0' ;
		assert (0 = to_integer(test_sl))
			report "in: " & to_string(test_sl)
			& ";  out: " & to_string(to_integer(test_sl)) 
			& ";  must be: " & to_string('1') severity error;
		wait for 1 ps;
		test_sl := '1';
		assert (1 = to_integer(test_sl))
			report "in: " & to_string(test_sl)
			& ";  out: " & to_string(to_integer(test_sl)) 
			& ";  must be: " & to_string('0') severity error;
		wait for 1 ps;
		
		report "sl to int check completed" severity warning;	 
		
		
		
		assert ('1' = to_std_logic(TRUE))
			report "in: " & "TRUE"
			& ";  out: " & to_string(to_std_logic(TRUE)) 
			& ";  must be: " & to_string('1') severity error;
		wait for 1 ps;
		assert ('0' = to_std_logic(FALSE))
			report "in: " & "FALSE"
			& ";  out: " & to_string(to_std_logic(FALSE)) 
			& ";  must be: " & to_string('0') severity error;

		wait for 1 ps; 
		
		report "bool to sl check completed" severity warning;	 
		

		test_char := '0';
		assert ("0000" = to_stdlogicvector(test_char))
			report "in: " & to_string(test_char)
			& ";  out: " & to_string(to_stdlogicvector(test_char)) 
			& ";  must be: " & "0000" severity error;
		wait for 1 ps; 
		
		test_char := '1';
		assert ("0001" = to_stdlogicvector(test_char))
			report "in: " & to_string(test_char)
			& ";  out: " & to_string(to_stdlogicvector(test_char)) 
			& ";  must be: " & "0001" severity error;
		wait for 1 ps; 	 
		
		test_char := '2';
		assert ("0010" = to_stdlogicvector(test_char))
			report "in: " & to_string(test_char)
			& ";  out: " & to_string(to_stdlogicvector(test_char)) 
			& ";  must be: " & "0010" severity error;
		wait for 1 ps; 	 
		
		test_char := '3';
		assert ("0011" = to_stdlogicvector(test_char))
			report "in: " & to_string(test_char)
			& ";  out: " & to_string(to_stdlogicvector(test_char)) 
			& ";  must be: " & "0011" severity error;
		wait for 1 ps;
		
		test_char := '4';
		assert ("0100" = to_stdlogicvector(test_char))
			report "in: " & to_string(test_char)
			& ";  out: " & to_string(to_stdlogicvector(test_char)) 
			& ";  must be: " & "0100" severity error;

		wait for 1 ps; 
		
		test_char := '5';
		assert ("0101" = to_stdlogicvector(test_char))
			report "in: " & to_string(test_char)
			& ";  out: " & to_string(to_stdlogicvector(test_char)) 
			& ";  must be: " & "0101" severity error;
		wait for 1 ps;
		
		test_char := '6';
		assert ("0110" = to_stdlogicvector(test_char))
			report "in: " & to_string(test_char)
			& ";  out: " & to_string(to_stdlogicvector(test_char)) 
			& ";  must be: " & "0110" severity error;
		wait for 1 ps; 	 
		
		test_char := '7';
		assert ("0111" = to_stdlogicvector(test_char))
			report "in: " & to_string(test_char)
			& ";  out: " & to_string(to_stdlogicvector(test_char)) 
			& ";  must be: " & "0111" severity error;
		wait for 1 ps; 
		
		test_char := '8';
		assert ("1000" = to_stdlogicvector(test_char))
			report "in: " & to_string(test_char)
			& ";  out: " & to_string(to_stdlogicvector(test_char)) 
			& ";  must be: " & "1000" severity error;
		wait for 1 ps; 
		
		test_char := '9';
		assert ("1001" = to_stdlogicvector(test_char))
			report "in: " & to_string(test_char)
			& ";  out: " & to_string(to_stdlogicvector(test_char)) 
			& ";  must be: " & "1001" severity error;
		wait for 1 ps; 
		
		report "char to slv check completed" severity warning;	
		
		report "STOP" severity warning;
		std.env.finish;
		
	end process sim;

end architecture rtl;
