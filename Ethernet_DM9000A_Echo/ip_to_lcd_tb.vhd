library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity IP_TO_LCD_tb is
end IP_TO_LCD_tb;
architecture tb of IP_TO_LCD_tb is
constant CLK_FREQ : integer := 50e6;
constant CLK_PERIOD : time := 1 sec/ CLK_FREQ;

signal  clk_tb          :   std_logic := '1';
signal  lcd_data_in_tb  :   std_logic_vector(31 downto 0):= (others => '0');
signal  e_tb            :   std_logic := '0';
signal  rs_tb           :   std_logic := '0';
signal  rw_tb           :   std_logic := '0';
signal  lcd_data_tb     :   std_logic_vector(7 downto 0):= (others => '0');
signal  lcd_on_tb       :   std_logic := '0';
signal  lcd_blon_tb     :   std_logic := '0';

begin 
    clk_tb <= not clk_tb after clk_period / 2;
    
    IP_TO_LCD: entity work.IP_TO_LCD
        port map( 
        clk          => clk_tb,        
        ip_addr_in   => lcd_data_in_tb,
        lcd_en       => e_tb,          
        lcd_rs       => rs_tb,         
        lcd_rw       => rw_tb,         
        lcd_data     => lcd_data_tb,   
        lcd_on       => lcd_on_tb,     
        lcd_blon     => lcd_blon_tb   
        );
        sim : process 
        variable cnt : integer range 0 to 15;
        begin 
            --wait for initializiation
            wait for 65 ms;  --next step sending IP
            lcd_data_in_tb <= X"691AEF01"; --105.26.239.1
            wait for 5 ms;
            lcd_data_in_tb <= X"0AFF010C"; --10.255.1.12
            wait for 4 ms;
            lcd_data_in_tb <= X"0CCDEF0C"; --12.205.239.12
            wait for 3 ms;
            lcd_data_in_tb <= X"92FF010C"; --146.255.1.12
            wait for 2 ms;
            lcd_data_in_tb <= X"11CDEF11"; --17.205.239.17
            wait for 1 ms;
            lcd_data_in_tb <= X"11101101"; --17.16.17.1
            wait for 5 ms;
            lcd_data_in_tb <= X"FFFFFFFF"; --255.255.255.255
            wait for 2 ms;
            lcd_data_in_tb <= X"00000000"; --0.0.0.0
            wait for 500 us;
            lcd_data_in_tb <= X"FFFFFFFF"; --255.255.255.255
            wait for 100 ms;
            lcd_data_in_tb <= X"0CCDEF0C"; --12.205.239.12
            wait for 2 ms;
            std.env.finish;
        end process sim;
end tb;
