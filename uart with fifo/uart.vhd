library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_fifo is
    generic (
        CLK_FREQ  : positive := 50e6;
        UBRR : positive := 2;
        D_WIDTH   : positive := 8;
        D_DEPTH   : positive := 8;
        
        PARITY    : natural range 0 to 1 := 1; -- on = 1, off = 0
        PARITY_EO : std_logic            := '1'; -- even = '0', odd = '1'
        MODE		: natural range 0 to 1 := 0; -- sync = 0, async = 1
        U2X			: natural range 0 to 1 := 0;
        
        NUM_STOP_BITS : positive range 1 to 2 := 1
        );
    port (
        xclk   : in std_logic;
        clk50  : in std_logic;
        reset : in std_logic;
        
        polarity : in std_logic; -- rising edge - '0', falling - '1'
        
        wr_fifo_en : in std_logic;
        tx_en   : in std_logic;
        tx_req  : in std_logic;
        fifo_tx_data : in std_logic_vector(D_WIDTH - 1 downto 0);
        tx_busy : out std_logic;
        tx      : out std_logic;
        tx_end  : out std_logic; -- txc
        tx_empty: out std_logic; --udre
        
        rx_en            : in std_logic;
        rx               : in std_logic;
        --rx_busy          : out std_logic;
        rd_rx_fifo       : in std_logic;
        
        rx_error_stopbit : out std_logic; -- fe
        rx_error_parity  : out std_logic; -- pe
        rx_not_empty     : out std_logic; -- rxc
        fifo_rx_data     : out std_logic_vector(D_WIDTH - 1 downto 0);
        
        fifo_full_tx        : out std_logic;
        fifo_empty_tx       : out std_logic;
        
        fifo_full_rx        : out std_logic;
        fifo_empty_rx       : out std_logic
        );
end entity uart_fifo;

architecture struct of uart_fifo is
    signal os_tick : std_logic;
    signal baud_tick : std_logic;
    signal tx_mult : std_logic_vector(D_WIDTH - 1 downto 0);
    signal rx_mult : std_logic_vector(D_WIDTH - 1 downto 0);
    signal clk : std_logic;
    signal mode_pol : std_logic_vector(1 downto 0);
    constant OS_RATE : positive := 2*(1+4*MODE)*(1+U2X);
    constant BAUD_RATE : positive := CLK_FREQ/(2*(1+4*MODE)*(1+U2X)*UBRR);
    signal ext_clk : std_logic;
    signal wr_en : std_logic;
    signal rd_en : std_logic;
    signal rd_rdy : std_logic;
    signal tx_data : std_logic_vector(D_WIDTH - 1 downto 0);
    signal rx_data : std_logic_vector(D_WIDTH - 1 downto 0);
    signal rx_busy : std_logic;
    
    component uart_clk is
        generic (
            CLK_FREQ  : positive;
            BAUD_RATE : positive;
            OS_RATE   : positive
            );
        port (
            clk   : in std_logic;
            reset : in std_logic;
            
            os_tick   : out std_logic := '0';
            baud_tick : out std_logic := '0'
            );
    end component uart_clk;
begin
    with polarity select ext_clk <=
    not xclk when '0',
    xclk when others;
    
    with mode select clk <=
    ext_clk when 0,
    clk50 when others;
    
    uar_clk_inst: uart_clk
    generic map (
        CLK_FREQ  => CLK_FREQ,
        BAUD_RATE => BAUD_RATE,
        OS_RATE => OS_RATE
        )
    port map (
        clk => clk,
        reset => reset,
        
        os_tick => os_tick,
        baud_tick => baud_tick
        );
    
    uart_rx: entity work.uart_rx(rtl)
    generic map(
        D_WIDTH => D_WIDTH,
        OS_RATE => OS_RATE,
        
        PARITY => PARITY,
        PARITY_EO => PARITY_EO,
        NUM_STOP_BITS => NUM_STOP_BITS
        )
    port map (
        clk	=> clk,
        reset => reset,
        os_tick	=> os_tick,
        
        en => rx_en,
        rx => rx,
        
        rx_not_empty => rx_not_empty,
        busy => rx_busy,
        error_stopbit => rx_error_stopbit,
        error_parity => rx_error_parity, 
        rx_data	=> rx_data
        ); 
    
    uart_tx: entity work.uart_tx(rtl)
    generic map(
        D_WIDTH => D_WIDTH,
        
        PARITY => PARITY,
        PARITY_EO => PARITY_EO,
        NUM_STOP_BITS => NUM_STOP_BITS
        )
    port map (
        clk	=> clk,
        reset => reset,
        baud_tick => baud_tick,
        en => tx_en,
        tx_end => tx_end,
        
        --tx_req => tx_req,
        tx_req => rd_rdy,
        tx_data => tx_data,
        
        busy => tx_busy,
        tx => tx,
        tx_empty => tx_empty
        );
    
    fifo_rx: entity work.fifo
    generic map(
        DEPTH => D_DEPTH,
        WIDTH => D_WIDTH
        )
    port map (
        CE => rx_en,
        CLR => reset,
        CLK => clk,
        RD => rd_rx_fifo,
        WR => wr_en,
        DATA => rx_data,
        Q => fifo_rx_data,
        
        empty => fifo_empty_rx,
        full => fifo_full_rx
        );
    
    fifo_tx: entity work.fifo
    generic map(
        DEPTH => D_DEPTH,
        WIDTH => D_WIDTH
        )
    port map (
        CE => tx_en,
        CLR => reset,
        CLK => clk,
        RD => rd_en,
        WR => wr_fifo_en,
        DATA => fifo_tx_data,
        Q => tx_data,
        
        empty => fifo_empty_tx,
        full => fifo_full_tx
        );
    
    --single pulse to write into fifo
    WRITE_ENABLE : entity work.single_pulse(rtl)
    port map (
        clk  => clk,
        sig  => rx_busy,
        slct => "01", -- falling edge
        
        pls  => wr_en       
        ); 
    
    --single pulse to get data from fifo
    READ_ENABLE : entity work.single_pulse(rtl)
    port map (
        clk  => clk,
        sig  => tx_req,
        slct => "00", -- rising edge
        
        pls  => rd_en       
        );
    
    -- single pulse to transfer data from fifo to tx
    READ_READY : entity work.single_pulse(rtl)
    port map (
        clk  => clk,
        sig  => rd_en,
        slct => "01", -- falling edge
        
        pls  => rd_rdy       
        );    
end architecture struct;
