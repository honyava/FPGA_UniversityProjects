library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity IE7_tb is
	
end IE7_tb;

architecture test of IE7_tb is
	constant CLK_FREQ : integer := 50e6;
	constant CLK_PERIOD : time := 1 sec/ CLK_FREQ;
	
	signal r_tb : STD_LOGIC := '0';
	signal wr_tb : STD_LOGIC := '1';
	
	signal dir_tb : STD_LOGIC := '1';
	signal rev_tb :  STD_LOGIC := '1';
	
	signal d_tb : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
	
	signal y_tb : std_logic_vector (3 downto 0) := (others => '0');
	
	signal cr_tb : std_logic := '0';
	signal br_tb : std_logic := '0';
	
	signal num : integer := 7;
	
	signal test_vec : std_logic_vector (3 downto 0) := (others => '0');
	
begin
	
	-- Connecting IE7 to our testbench
	ie7: entity work.ie7 (rtl)
	port map( 
		
		r => r_tb,
		wr => wr_tb,
		dir => dir_tb,
		rev => rev_tb,
		d => d_tb, 
		y => y_tb,
		cr => cr_tb,
		br => br_tb
		);
	
	sim: process
		variable check: integer := 0;
	begin
		report "Start test";
		
		--resetting counter state
		r_tb <= '1';
		wait for 2*CLK_PERIOD;
		r_tb <= '0';
		wait for 2*CLK_PERIOD;
		
		assert (y_tb, br_tb, cr_tb) = "000011"
		report "No reset done" severity error; 
		
		--setting cnt as in signal
		d_tb <= std_logic_vector(to_unsigned(num,4));
		
		--writing in signal to out signal
		wr_tb <= '0';
		wait for 2*CLK_PERIOD;
		wr_tb <= '1';
		assert y_tb = d_tb
		report "No writing done" severity error; 
		
		rev_tb <= '1';
		for i in 0 to 15 loop
			dir_tb <= not dir_tb;
			wait for CLK_PERIOD/2;
			
			check := num + 1 + i;
			
			if check > 15 then
				check := check - 16;
			end if;
			
			test_vec <= std_logic_vector(to_unsigned(check, 4));
			
			dir_tb <= not dir_tb;
			wait for CLK_PERIOD/2;			
			
			
			assert y_tb = test_vec;
			report "out: " & to_string(y_tb) & " should: " & to_string(test_vec) severity warning; 
		end loop; 
		
		dir_tb <= '1';			
		for i in 0 to 15 loop
			rev_tb <= not rev_tb;
			wait for CLK_PERIOD/2;
			
			check := num - 1 - i;
			
			if check < 0 then
				check := check + 16;
			end if;
			
			test_vec <= std_logic_vector(to_signed(check, 4));
			
			rev_tb <= not rev_tb;
			wait for CLK_PERIOD/2;
			
			assert y_tb = test_vec;
			report "out: " & to_string(y_tb) & " should: " & to_string(test_vec) severity warning; 
		end loop;
		
		wait for 2*CLK_PERIOD;
		
		for i in 0 to 7 loop
			rev_tb <= not rev_tb;
			dir_tb <= not dir_tb;
			wait for CLK_PERIOD/2;
		end loop;
		report "Finish test" severity warning;
		std.env.finish;
	end process;
	
end test;
