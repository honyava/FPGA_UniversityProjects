library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;	

package converters is
	function to_grey_code(value : std_logic_vector) return std_logic_vector;
	function to_bin_code(value : std_logic_vector) return std_logic_vector;
end package converters; 

package body converters is
	
	function to_grey_code(value : std_logic_vector) return std_logic_vector is
    begin
		return(value xor (value srl 1));
    end function to_grey_code;	 
	
	function to_bin_code(value : std_logic_vector) return std_logic_vector is  
	variable i : integer := 0; 
	variable temp : std_logic_vector (value'length-1 downto 0) := value; 
	variable output : std_logic_vector (value'length-1 downto 0) := value; 
    begin
		for i in 0 to value'length-1 loop	   
			output := output xor (temp srl 1); 
			temp := (temp srl 1);
		end loop; 
		
		return(output);
    end function to_bin_code;
	
	
end package body converters;