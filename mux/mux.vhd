library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux8 is
    port (
	input0 : std_logic := '0';
	input1 : in std_logic := '0';	
	input2 : in std_logic := '0';	
	input3 : in std_logic := '0';	
	input4 : in std_logic := '0';	
	input5 : in std_logic := '0';	
	input6 : in std_logic := '0';	
	input7 : in std_logic := '0';	
	
	adr : in std_logic_vector (2 downto 0); 
	
	en : in std_logic := '0';
	
	output : out std_logic := '0'
    );
end entity mux8;
				

architecture rtl of mux8 is
begin
    with (adr, en) select output <=
        input0 when "0000",
        input1 when "0010",
        input2 when "0100",
		input3 when "0110",
        input4 when "1000",
        input5 when "1010",
		input6 when "1100",
        input7 when "1110",
        'Z' when others;
end;
