library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity uart_tx is
    generic (
        D_WIDTH  : positive := 8;
        
        PARITY        : natural range 0 to 1  := 1;
        PARITY_EO     : std_logic             := '0';
        NUM_STOP_BITS : positive range 1 to 2 := 1
        );
    port (
        clk       : in std_logic;
        reset     : in std_logic;
        baud_tick : in std_logic;
        
        en        : in std_logic;
        
        tx_req  : in std_logic;
        tx_data : in std_logic_vector(D_WIDTH-1 downto 0);
        
        busy : out std_logic;
        tx   : out std_logic;
        tx_end : out std_logic;
        tx_empty : out std_logic
        );
end entity uart_tx;

architecture rtl of uart_tx is
    type   state_t is (idle, start, shift_data, stop);
    signal state      : state_t;
    signal parity_bit : std_logic;
    signal shift_reg  : std_logic_vector(D_WIDTH-1 downto 0) := (others => '1');
    signal start_bit      : std_logic := '1';
begin
    
    process (clk, reset) is
        variable count_data     : natural range 0 to D_WIDTH + PARITY := 0;
        variable count_stopbits : natural range 0 to NUM_STOP_BITS := 0;
    begin
        if reset = '1' then
            count_data     := 0;
            count_stopbits := 0;
            tx             <= '1';
            busy           <= '0';
            tx_end         <= '0';
            tx_empty       <= '1';
            state          <= idle;
        elsif rising_edge(clk) then
            
            case state is
                
                when idle =>
                    if tx_req = '1' and en = '1' then
                        shift_reg  <= tx_data;
                        tx_empty <= '0';
                        parity_bit <= xor_reduce(tx_data) xor PARITY_EO;
                        busy       <= '1';
                        count_data := 0;
                        tx_end     <= '0';
                        --
                        state <= start;
                    else
                        busy <= '0';
                        --
                        state <= idle;
                    end if;
                
                when start =>
                    if baud_tick = '1' then
                        tx <= '0';
                        --
                        state <= shift_data;
                    end if;
                
                when shift_data =>
                    if baud_tick = '1' then
                        tx         <= shift_reg(0);
                        shift_reg  <= parity_bit & shift_reg(D_WIDTH -1 downto 1);
                        count_data := count_data + 1;
                        if count_data = D_WIDTH + PARITY then
                            count_data := 0;
                            --
                            state <= stop;
                        end if;
                    end if;
                
                when stop =>
                    if baud_tick = '1' then
                        tx             <= '1';
                        count_stopbits := count_stopbits + 1;
                        if count_stopbits = NUM_STOP_BITS then
                            count_stopbits := 0;
                            busy           <= '0';
                            tx_end         <= '1';
                            tx_empty       <= '1';
                            --
                            state <= idle;
                        end if;
                end if;
            end case;
        end if;
    end process;
    
end architecture rtl;
