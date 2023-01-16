-------------------------------------------------------------------------------
--
-- Title       : IE7
-- Design      : sem6_4
-- Author      : Компьютер
-- Company     : 232
--
-------------------------------------------------------------------------------
--
-- File        : c:\My_Designs\sem6_4\sem6_4\src\IE7.vhd
-- Generated   : Wed Oct 12 23:08:50 2022
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.22
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {IE7} architecture {rtl}}

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity IE7 is
	port(
		r : in STD_LOGIC;
		wr : in STD_LOGIC;
		dir : in STD_LOGIC;
		rev : in STD_LOGIC;
		d : in STD_LOGIC_VECTOR(3 downto 0); 
		y : out std_logic_vector (3 downto 0);
		cr : out std_logic;
		br: out std_logic
		);
end IE7;

architecture rtl of IE7 is
begin
	
	process (dir, rev, wr, r)
		variable cnt: integer range 0 to 15 := 0 ;
		
	begin	
		if r = '1' then
			
			y <= (others => '0');
			
		else 
			
			if wr = '0' then
				
				y <= d;
				cnt := to_integer(unsigned(d));
				
			else 
				cr <= '1';
				br <= '1';
				
				if (rising_edge(dir) and rev = '1') and not rising_edge(rev) then
					if cnt = 15 then
						cr <= '1';
						cnt := 0;
					else
						cnt := cnt + 1;
					end if;					
					y <= std_logic_vector(to_unsigned(cnt, 4));
				elsif rising_edge(rev) and dir = '1' and not rising_edge(dir) then
					if cnt = 0 then
						br <= '1';
						cnt := 15;
					else
						cnt := cnt - 1;
					end if;
					y <= std_logic_vector(to_unsigned(cnt, 4));
				elsif falling_edge(dir) and cnt = 15 and rev = '1' then
					cr <= '0';
				elsif falling_edge(rev) and cnt = 0 and dir = '1' then
					br <= '0';
				end if;				
				
			end if;
			
		end if;	
	end process;
	
end rtl;
