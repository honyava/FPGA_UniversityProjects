library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity lcd_test is
    port (
        clk          : in  std_logic;
        lcd_data_in  : in std_logic_vector(31 downto 0) := (others => '0');
        e            : out std_logic;
        rs           : out std_logic;
        rw           : out std_logic;
        lcd_data     : out std_logic_vector(7 downto 0);
        lcd_on       : out std_logic;
        lcd_blon     : out std_logic);
    
end lcd_test;

architecture Behavioral of lcd_test is
   
    signal reset_n_temp : std_LOGIC;
    signal lcd_enable_temp : std_LOGIC;
    signal lcd_bus_temp :  STD_LOGIC_VECTOR(9 DOWNTO 0); --data and control signals
    signal busy_temp : std_LOGIC;
    
    COMPONENT ControllerTest_TOP IS
        PORT(
            lcd_busy : IN STD_LOGIC; --lcd controller busy/idle feedback
            clk : IN STD_LOGIC; --system clock  
            lcd_data_in : in STD_LOGIC_VECTOR(31 DOWNTO 0);
            reset_n : OUT STD_LOGIC;
            lcd_enable : buffer STD_LOGIC; --lcd enable received from lcd controller
            lcd_bus : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)); --data and
        --control signals
        --The MSB is the rs signal, followed by the rw signal.
        -- The other 8 bits are the data bits.
    END COMPONENT;
    
    COMPONENT lcd_controller IS
        PORT(
            clk        : IN    STD_LOGIC;  --system clock
            reset_n    : IN    STD_LOGIC;  --active low reinitializes lcd
            lcd_bus : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            lcd_enable : IN STD_LOGIC; --latches data into lcd controller
            rw, rs, e  : OUT   STD_LOGIC;  --read/write, setup/data, and enable for lcd
            lcd_data   : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0); --data signals for lcd
            busy  : OUT   STD_LOGIC;	
            lcd_on : OUT std_logic; --LCD Power ON/OFF
            lcd_blon : OUT std_logic); --LCD Back Light ON/OFF
    END COMPONENT;
  
begin
    
    LCD_user: ControllerTest_TOP port map(
        
        clk => clk,
        lcd_data_in => lcd_data_in,
        reset_n => reset_n_temp,
        lcd_enable => lcd_enable_temp,
        lcd_bus => lcd_bus_temp,
        lcd_busy => busy_temp
        );
    LCD_contr: lcd_controller port map(
        
        clk => clk,
        reset_n => reset_n_temp,
        lcd_enable => lcd_enable_temp,
        lcd_bus => lcd_bus_temp,
        busy => busy_temp,
        rw => rw,
        lcd_data => lcd_data,
        e => e,
        rs => rs,
        lcd_on => lcd_on,
        lcd_blon => lcd_blon
        );
    
end Behavioral;