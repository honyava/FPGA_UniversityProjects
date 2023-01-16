library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package converters is
	function to_integer(value : std_logic_vector) return integer;
	function to_integer(value : std_logic) return integer;
	function to_stdlogic(value : boolean) return std_logic;
	function to_stdlogicvector(value : integer; length : integer) return std_logic_vector;
	function to_stdlogicvector(char : character) return std_logic_vector;
	
	
	alias to_std_logic is to_stdlogic[boolean return std_logic];
	alias to_sl is to_stdlogic[boolean return std_logic];
	alias to_std_logic_vector is to_stdlogicvector[integer, integer return std_logic_vector];
	alias to_slv is to_stdlogicvector[integer, integer return std_logic_vector];
	alias to_std_logic_vector is to_stdlogicvector[character return std_logic_vector];
	alias to_slv is to_stdlogicvector[character return std_logic_vector];
end package converters; 

package body converters is	
	
	function to_integer(value : std_logic_vector) return integer is
	variable temp : std_logic_vector (value'length-1 downto 0) := value; 
	variable output : integer := 0; 
    begin
		for i in 0 to value'length-1 loop 
			if (temp(i) = '1') then
				output := output + (2 ** i);
			end if;
		end loop;
		return(output);
    end function to_integer;
	
	
	
	function to_integer(value : std_logic) return integer is
	variable temp : std_logic := value; 
    begin
		if (temp = '1') then
			return(1);
		else
			return(0);
		end if;
    end function to_integer; 
	
	
	
	function to_stdlogic(value : boolean) return std_logic is
	variable temp : boolean := value; 
	variable output : integer := 0; 
    begin
		if (temp = TRUE) then 
			return('1');
		else
			return('0');
		end if;
    end function to_stdlogic;
	
	
	
	function to_stdlogicvector(value : integer; length : integer) return std_logic_vector is
    begin
		return(std_logic_vector(to_signed(value, length)));
    end function to_stdlogicvector;	
	
	
	
	function to_stdlogicvector(char : character) return std_logic_vector is	  
		variable output : std_logic_vector(3 downto 0) := (others => '0'); 
    begin
        with (char) select output:=							 
		"0000" when '0',
		"0001" when '1',
		"0010" when '2',
		"0011" when '3',
		"0100" when '4',
		"0101" when '5',
		"0110" when '6',
		"0111" when '7',
		"1000" when '8',
		"1001" when '9',
		"0000" when others;	
		return(output);
    end function to_stdlogicvector;
	
end package body converters;