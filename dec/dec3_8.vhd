library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dec3_8 is
    port (
	en : in  std_logic; 
	x  : in  std_logic_vector (2 downto 0);
	y  : out std_logic_vector (7 downto 0)  
    );
end entity dec3_8;
				

architecture rtl of dec3_8 is
begin
	with (x, en) select y <=							 
        (0 => '1', others => '0') when "0001",
        (1 => '1', others => '0') when "0011",
        (2 => '1', others => '0') when "0101",
		(3 => '1', others => '0') when "0111",
        (4 => '1', others => '0') when "1001",
        (5 => '1', others => '0') when "1011",
		(6 => '1', others => '0') when "1101",
        (7 => '1', others => '0') when "1111",
        (		   others => 'Z') when others;
end;

