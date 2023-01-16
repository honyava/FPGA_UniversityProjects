library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shiftN is  
	
	generic (		  
	N : natural := 8
	);
	
    port (
	d : in std_logic;
	clk : in std_logic;
	r : in std_logic;
	q : out std_logic_vector(N-1 downto 0) := (others => '0')
    ); 
	 
end entity shiftN;

architecture rtl of shiftN is
begin
    process (clk)
    begin
		if (r = '0') then
			if (clk'event and clk = '1') then
				q <= q sll 1;
				q(0) <= d;
			end if;
		else
			q <= (others => 'Z');	
		end if;

    end process;
end architecture rtl;
