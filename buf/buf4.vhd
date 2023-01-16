library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity buf4 is
    port (
	en : in std_logic; 
	
	x : in std_logic_vector (3 downto 0);
	
	y : out std_logic_vector (3 downto 0)  
    );
end entity buf4;
				

architecture rtl of buf4 is
begin
	with en select y <=							 
        x when '1',
        (others => 'Z') when others;
end;

