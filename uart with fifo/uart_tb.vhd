library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity uart_tb is
    
end entity uart_tb; 

architecture test of uart_tb is
    constant CLK_FREQ  : positive := 50e6;   
    constant CLK_PERIOD : time := 1 sec/ CLK_FREQ;
    
    constant UBRR : positive := 2;
    constant D_WIDTH   : positive := 8;
    constant D_DEPTH   : positive := 4;
    
    constant PARITY    : natural range 0 to 1 := 1; -- on = 1, off = 0
    constant PARITY_EO : std_logic            := '1'; -- even = '0', odd = '1'
    constant MODE		: natural range 0 to 1 := 1; -- sync = 0, async = 1
    constant U2X			: natural range 0 to 1 := 0;
    constant NUM_STOP_BITS : positive range 1 to 2 := 1;
    
    constant OS_RATE : positive := 2*(1+4*MODE)*(1+U2X);
    
    signal xclk : std_logic := '0';
    signal clk50 : std_logic := '1';
    signal reset : std_logic := '0';
    signal polarity : std_logic := '0';
    
    signal wr_fifo_en : std_logic := '0';
    signal tx_en : std_logic := '0';
    signal tx_req  : std_logic := '0';
    signal fifo_tx_data : std_logic_vector(D_WIDTH - 1 downto 0);
    signal tx_busy : std_logic;
    signal tx      : std_logic;
    signal tx_end  : std_logic; -- txc
    signal tx_empty : std_logic;  --udre
    
    signal rd_rx_fifo       : std_logic := '0';
    signal rx_en            : std_logic := '0';
    signal rx               : std_logic := '1';
    --signal rx_busy          :  std_logic;
    signal rx_error_stopbit :  std_logic; -- fe
    signal rx_error_parity  :  std_logic; -- pe
    signal rx_not_empty     :  std_logic; -- rxc
    signal fifo_rx_data          :  std_logic_vector(D_WIDTH - 1 downto 0);
    
    constant BAUD_RATE : positive := CLK_FREQ/(2*(1+4*MODE)*(1+U2X)*UBRR);
    constant OS_DIV   : positive := CLK_FREQ / (BAUD_RATE * OS_RATE);
    
    signal fifo_empty_tx       : std_logic;
    signal fifo_full_tx        : std_logic;
    
    signal fifo_empty_rx       : std_logic;
    signal fifo_full_rx        : std_logic;
    
    alias os_tick is << signal uart.os_tick : std_logic>>;
    alias wr_en is << signal uart.wr_en : std_logic>>;
    alias rd_en is << signal uart.rd_en : std_logic>>;
    alias rd_rdy is << signal uart.rd_en : std_logic>>;
    alias rx_busy is <<signal uart.rx_busy : std_logic>>;
begin 
    
    clk50 <= not clk50 after CLK_PERIOD/2;
    xclk <= not xclk after CLK_PERIOD;
    
    uart: entity work.uart_fifo
    generic map (
        CLK_FREQ  => CLK_FREQ,
        UBRR => UBRR,
        D_WIDTH => D_WIDTH,
        D_DEPTH => D_DEPTH,
        
        PARITY  => PARITY,
        PARITY_EO => PARITY_EO,
        MODE => MODE,
        U2X => U2X,
        
        NUM_STOP_BITS => NUM_STOP_BITS
        )
    port map (
        xclk   => xclk,
        clk50 => clk50,
        reset => reset,
        
        polarity => polarity,
        
        wr_fifo_en => wr_fifo_en,
        tx_en  => tx_en,
        tx_req  => tx_req,
        fifo_tx_data => fifo_tx_data,
        tx_busy => tx_busy,
        tx      => tx,
        tx_end  => tx_end,
        tx_empty => tx_empty,
        
        rx_en            => rx_en,
        rx               => rx,
        --rx_busy          => rx_busy,
        rd_rx_fifo       => rd_rx_fifo,
        
        rx_error_stopbit => rx_error_stopbit,
        rx_error_parity  => rx_error_parity,
        rx_not_empty     => rx_not_empty,
        fifo_rx_data     => fifo_rx_data,
        
        fifo_full_tx        => fifo_full_tx,
        fifo_empty_tx       => fifo_empty_tx,
        
        fifo_full_rx        => fifo_full_rx,
        fifo_empty_rx       => fifo_empty_rx
        );
    
    rx <= tx;
    
    sim : process
    begin
        reset <= '1';
        wait for CLK_PERIOD/3;
        
        reset <= '0';
        tx_en <= '1';
        wr_fifo_en <= '1'; 
        
        -- tx fifo check
        for i in 1 to D_DEPTH loop
            fifo_tx_data <= std_logic_vector(to_unsigned(5*i, fifo_tx_data'length));
            wait until rising_edge(clk50);
            wait for 4 ns;
        end loop;
        
        wr_fifo_en <= '0';
        wait for 10*CLK_PERIOD;
        rx_en <= '1';
        
        for i in 1 to D_DEPTH loop
            tx_req <= '1';
            wait until falling_edge(tx_busy);
            tx_req <= '0';
            wait for 2*CLK_PERIOD;
        end loop;
        
        -- rx fifo check
        wait until falling_edge(rx_busy);
        rd_rx_fifo <= '1';
        wait for 5*CLK_PERIOD;
        rd_rx_fifo <= '0';
        
        std.env.finish;
        
    end process;
    
end test;
