library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;

entity uart_rx is
    generic (
        D_WIDTH : positive := 8;
        OS_RATE : positive := 16;
        
        PARITY        : natural range 0 to 1  := 1;
        PARITY_EO     : std_logic             := '0';
        NUM_STOP_BITS : positive range 1 to 2 := 1
        );
    port (
        clk     : in std_logic;
        reset   : in std_logic;
        os_tick : in std_logic;
        
        en : in std_logic;
        
        rx : in std_logic;
        
        rx_not_empty  : out std_logic;
        busy          : out std_logic;
        error_stopbit : out std_logic;
        error_parity  : out std_logic;
        rx_data       : out std_logic_vector(D_WIDTH - 1 downto 0)
        );
end entity uart_rx;

architecture rtl of uart_rx is
    type   state_t is (idle, start, shift_data, stop);
    signal state : state_t;
    
    signal rx_reg    : std_logic_vector(2 downto 0) := (others => '0');
    signal rx_filter : std_logic := '0';
    
    signal shift_reg : std_logic_vector(D_WIDTH + PARITY - 1 downto 0) := (others => '0');
begin
    
    process (clk, reset) is
        variable sum_rx_reg : std_logic_vector(1 downto 0) := (others => '0');
    begin
        if reset = '1' then
            rx_reg <= (others => '0');
        elsif rising_edge(clk) then
            if os_tick = '1' then
                rx_reg(0) <= rx;
                rx_reg(1) <= rx_reg(0);
                rx_reg(2) <= rx_reg(1);
                
                sum_rx_reg := ('0' & rx_reg(0)) + ('0' & rx_reg(1)) + ('0' & rx_reg(2));
                if sum_rx_reg > "01" then
                    rx_filter <= '1';
                else
                    rx_filter <= '0';
                end if;
            end if;
        end if;
    end process;
    
    process (clk, reset) is
        variable count_os_tick   : integer range 0 to OS_RATE          := 0;
        variable count_data      : integer range 0 to D_WIDTH + PARITY := 0;
        variable count_stop_bits : natural range 0 to NUM_STOP_BITS;
    begin
        if reset = '1' then
            count_os_tick   := 0;
            count_data      := 0;
            count_stop_bits := 0;
            
            rx_not_empty  <= '0';
            busy          <= '0';
            error_stopbit <= '0';
            error_parity  <= '0';
            rx_data       <= (others => '0');
            --
            state <= idle;
        elsif rising_edge(clk) then
            if os_tick = '1' then
                case state is
                    
                    when idle =>
                        if not rx_reg(0) and rx_reg(1) and en then
                            busy <= '1';
                            --
                            
                            state <= start;
                            
                        end if;
                    
                    when start =>
                        
                        count_os_tick := count_os_tick + 1;
                        if count_os_tick = OS_RATE / 2 + 1 then
                            count_os_tick := 0;
                            if rx_filter = '0' then
                                --
                                state <= shift_data;
                            else
                                busy <= '0';
                                --
                                state <= idle;
                            end if;
                        end if;
                    
                    when shift_data =>
                        
                        count_os_tick := count_os_tick + 1;
                        if count_os_tick = OS_RATE then
                            count_os_tick := 0;
                            shift_reg     <= rx_filter & shift_reg(shift_reg'left downto 1);
                            rx_not_empty <= '1';
                            count_data    := count_data + 1;
                        end if;
                        if count_data = D_WIDTH + PARITY then
                            count_data := 0;
                            --
                            state <= stop;
                        end if;
                    
                    when stop =>
                        
                        count_os_tick := count_os_tick + 1;
                        if count_os_tick = OS_RATE then
                            count_os_tick := 0;
                            if rx_filter = '0' then
                                error_stopbit <= '1';
                            end if;
                            count_stop_bits := count_stop_bits + 1;
                        end if;
                        if count_stop_bits = NUM_STOP_BITS then
                            count_stop_bits := 0;
                            error_parity    <= xor_reduce(shift_reg) xor PARITY_EO;
                            rx_data         <= shift_reg(rx_data'range);
                            rx_not_empty    <= '0';
                            busy            <= '0';
                            --
                            state <= idle;
                    end if;
                end case;
            end if;
        end if;
    end process;
    
end architecture rtl;
