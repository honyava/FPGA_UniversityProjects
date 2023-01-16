library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package tools is
	function razr(value : integer) return integer;
	function symb_bindec(value : integer) return std_logic_vector;
	function symb_bindec_inv(value : std_logic_vector) return integer;
	function dec_to_bindec(value : integer) return std_logic_vector; 
	function bindec_to_dec( value : std_logic_vector) return integer;
end package tools; 

package body tools is	
	
	function razr( value : integer ) return integer is
        variable temp : integer := value ;
        variable n : integer := 0 ;
		variable r : std_logic_vector (3 downto 0) := (others => '0');
    begin
        while temp > 0 loop
            temp := temp / 10 ;
            n := n + 1 ;
        end loop ; 	
		return (n);
    end function razr;	 
	
	
	
	function symb_bindec( value : integer ) return std_logic_vector is
        variable temp : integer := value ;
		variable r : std_logic_vector (3 downto 0) := (others => '0');
    begin  
        with (temp) select r :=							 
				"0000" when 0,
				"0001" when 1,
				"0010" when 2,
				"0011" when 3,
				"0100" when 4,
				"0101" when 5,
				"0110" when 6,
				"0111" when 7,
				"1000" when 8,
				"1001" when 9,
				"0000" when others;		
		return (r);
    end function symb_bindec; 
	
	
	
	
	function symb_bindec_inv( value : std_logic_vector ) return integer is
        variable  code : std_logic_vector (3 downto 0) := value;
		variable  num : integer := 0;
    begin  
        with code select num :=							 
				0 when "0000",
				1 when "0001",
				2 when "0010",
				3 when "0011",
				4 when "0100",
				5 when "0101",
				6 when "0110",
				7 when "0111",
				8 when "1000",
				9 when "1001",
				0 when others;		
		return (num);
    end function symb_bindec_inv;
	
	
	
	function dec_to_bindec( value : integer) return std_logic_vector is
        variable temp : integer := value ;
		variable r : std_logic_vector (3 downto 0) := (others => '0');  
		variable n : integer := razr(value);
		variable output : std_logic_vector (n*4 - 1 downto 0) := (others => '0'); 
		variable i : integer := 0 ;
    begin	
		while (i < n*4) loop
			if (temp > 9) then 
				r := symb_bindec(temp rem 10);
			else
				r := symb_bindec(temp);
			end if;
			output(i) := r(0);
			output(i+1) := r(1);
			output(i+2) := r(2);
			output(i+3) := r(3);
			i := i + 4;	
			temp := temp / 10;
		end loop;
		return(output); 
    end function dec_to_bindec;
	
	
	
	function bindec_to_dec( value : std_logic_vector) return integer is
        variable temp : std_logic_vector (value'length-1 downto 0) := value;
		variable r : std_logic_vector (3 downto 0) := (others => '0');  
		variable i : integer := 0 ;	   
		variable num : integer := 0 ;
		variable n : integer := value'length / 4;
		variable output : integer := 0 ;
    begin	
		while (i < n*4) loop
			r(3) := temp((temp'length-1)-i);
			r(2) := temp((temp'length-1)-i-1);
			r(1) := temp((temp'length-1)-i-2);
			r(0) := temp((temp'length-1)-i-3);
			
			num := symb_bindec_inv(r);
			
			output := output * 10 + num;
			
			i := i + 4;	
		end loop;
		return(output); 
    end function bindec_to_dec;
	
	
end package body tools;