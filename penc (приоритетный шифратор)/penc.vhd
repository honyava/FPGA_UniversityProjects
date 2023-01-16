library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity penc is  
	
	generic (		  
	N : natural := 2
	);
	
    port (
	input  : in  std_logic_vector (2**N - 1 downto 0);
	r      : in  std_logic; 
	output : out std_logic_vector (N - 1 downto 0)
    ); 
	 
end entity penc;

architecture rtl of penc is	
	signal zeros : std_logic_vector (2**N - 1 downto 0) := (others => '0'); 
begin
    process (input, r)
	variable pos : integer;	
	variable i   : integer; 
    begin
		if ((r = '0') and (input /= zeros)) then 
			pos := 0;
			i := input'length - 1; 
			seach : loop   
				if (input(i) = '1') then
					pos := i;
					exit;
				end if; 
				i := i - 1;
				exit when i = 0;
			end loop seach;	 
			
			output <= std_logic_vector(to_unsigned(pos,output'length));	 
			
		else
			output <= (others => 'Z');
		end if;
	
    end process;
end architecture rtl;
