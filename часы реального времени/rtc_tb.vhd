library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library aldec;
use aldec.aldec_tools.all;

entity rtc_tb is
	
end entity rtc_tb;

architecture test of rtc_tb is
	
	constant CLK_FREQ_TB : integer := 1000;
	constant CLK_PERIOD_TB : time := 1 sec/ CLK_FREQ_TB;
	
	signal clk_tb : std_logic := '0';
	signal rst_tb : std_logic:= '0';
	
	signal seconds_tb : natural := 0;
	signal minutes_tb : natural := 0;
	signal hours_tb   : natural := 0;
	
begin
	rtc: entity work.rtc
	generic map (
		CLK_FREQ => CLK_FREQ_TB
		)
	port map (
		clk => clk_tb,
		rst => rst_tb,
		
		seconds => seconds_tb,
		minutes => minutes_tb,
		hours => hours_tb
		);
	sim: process
		variable real_time : time := 0 ns;
		variable real_seconds : integer := 0;
		variable real_minutes : integer := 0;
		variable real_hours : integer := 0;
		
	begin
		rst_tb <= '1';
		wait for 2*CLK_PERIOD_TB;
		rst_tb <= '0';
		
		real_time := now;
		report "current time1 = " & time'image(now);
		for i in 0 to 2*CLK_FREQ_TB*240 loop
			clk_tb <= not clk_tb;
			wait for CLK_PERIOD_TB/ 2;
		end loop;
		real_time := (now - real_time);
		real_seconds := integer(floor(to_real(real_time)*get_resolution));
		
		real_minutes := integer(floor(real(real_seconds)/real(60)));
		real_seconds := real_seconds - 60*real_minutes;
		
		real_hours := integer(floor(real(real_minutes)/real(60)));
		real_minutes := real_minutes - 60*real_hours;
		
		assert seconds_tb = real_seconds
		report "out seconds: " & to_string(seconds_tb) &
		"; should be: " & to_string(real_seconds)
		severity error;
		
		assert minutes_tb = real_minutes
		report "out minutes: " & to_string(minutes_tb) &
		"; should be: " & to_string(real_minutes)
		severity error;
		
		assert hours_tb = real_hours
		report "out hours: " & to_string(hours_tb) &
		"; should be: " & to_string(real_hours)
		severity error;
		
		report "current time2 = " & time'image(now);
		report "simulation time_1 = " & to_string(real_time);
		report "simulation time in seconds = " & to_string(real_seconds) & " s";
		report "simulation time in minutes = " & to_string(real_minutes) & " min";
		report "Finish test" severity warning;
		std.env.finish;
		
	end process sim;
	
	
end architecture test;