library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.DM9000A_lib.all;

entity DM9000A is
    port (
--        RAM_ADDR   : out natural range 0 to 2**ADDR_WIDTH - 1;
--        RAM_DATA   : out std_logic_vector((DATA_WIDTH-1) downto 0);
--        RAM_WR     : out std_logic;
--        --RAM_RST    : out std_logic;
--        RAM_OUT    : in std_logic_vector((DATA_WIDTH-1) downto 0);
        
        state      : in state_type;
        
        clk        : in std_logic;
        clk_count  : in std_logic_vector(31 downto 0);
        rst_req    : inout std_logic;
        tx_req     : inout std_logic;
        rx_req     : inout std_logic;
        rst_event  : in std_logic_vector(31 downto 0);
        rx_event   : in std_logic_vector(31 downto 0);
        tx_event   : in std_logic_vector(31 downto 0);
        
        ENET_INT   : in    std_logic;
        ENET_RD_N  : out   std_logic;
        ENET_WR_N  : out   std_logic;
        ENET_CMD   : out   std_logic;
        ENET_DATA  : in std_logic_vector(15 downto 0);
        ENET_DATAo : out std_logic_vector(15 downto 0);
        ENET_tri   : out std_logic
    );
end DM9000A;

architecture rtl of DM9000A is    
    signal data_int     : std_logic_vector(15 downto 0) := (others => '0');
    signal rx_status    : std_logic_vector(15 downto 0) := (others => '0');
    signal rx_length    : std_logic_vector(15 downto 0) := (others => '0');
    signal rx_int       : std_logic_vector(15 downto 0) := (others => '0');
    
    constant rx_buf_len : natural := 32;
    
    type memory_t is array(2**10-1 downto 0) of std_logic_vector(15 downto 0);
    signal buf : memory_t;
    
begin  
 
    process(clk)
    begin   
        if rising_edge(clk) then
            if state = RESET then
            
 -- Probably need to clear some arrays
                -- Set inernal PHY (GPIO normal settings)
                IO_WRITE_DATA(GPCR, 16X"01", rst_event + cmd_delay * 1, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                IO_WRITE_DATA(GPR,  16X"00", rst_event + cmd_delay * 2, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);

                -- Software reset (RST bit in NCR set low)
                IO_WRITE_DATA(NCR, 16X"00", rst_event + cmd_delay * 3, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);

                -- wait for 5 ms (250 000 cycles of 20 ns = 20833 * 12 cycles)
                IO_WRITE_DATA(NCR, 16X"03", rst_event + delay_5m + cmd_delay * 1, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                IO_WRITE_DATA(NCR, 16X"00", rst_event + delay_5m + delay_20u + cmd_delay * 2, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                
                -- Turn internal PHY on and off
                IO_WRITE_DATA(GPR, 16X"01", rst_event + delay_5m + delay_20u + cmd_delay * 3, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                IO_WRITE_DATA(GPR, 16X"00", rst_event + delay_5m + delay_20u + cmd_delay * 4, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);

                -- Wait for 5 ms
                IO_WRITE_DATA(GPR, 16X"00", rst_event + delay_5m * 2 + cmd_delay * 1, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                IO_WRITE_DATA(GPR, 16X"80", rst_event + delay_5m * 2 + cmd_delay * 2, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                
                -- Store MAC address into NIC
                IO_WRITE_DATA(X"10", src_mac_addr(15 downto 0),  rst_event + delay_5m * 2 + cmd_delay * 3, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                IO_WRITE_DATA(X"12", src_mac_addr(31 downto 16), rst_event + delay_5m * 2 + cmd_delay * 4, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                IO_WRITE_DATA(X"14", src_mac_addr(47 downto 32), rst_event + delay_5m * 2 + cmd_delay * 5, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                
                -- Clear any pending interrupt
                IO_WRITE_DATA(ISR, 16X"3F", rst_event + delay_5m * 2 + cmd_delay * 6, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                IO_WRITE_DATA(NSR, 16X"2C", rst_event + delay_5m * 2 + cmd_delay * 7, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                
                -- Program operating registers
                -- NCR (Normal Loopback Mode, Full-Duplex)
                IO_WRITE_DATA(NCR,   16X"08", rst_event + delay_5m * 2 + cmd_delay * 8, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                -- WCR (Clear all events)
                IO_WRITE_DATA(WCR,   16X"00", rst_event + delay_5m * 2 + cmd_delay * 9, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                -- TCR2 (LED Mode 1)
                IO_WRITE_DATA(TCR2,  16X"80", rst_event + delay_5m * 2 + cmd_delay * 10, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                -- Clear LSB of packet length
                IO_WRITE_DATA(TXPLL, 16X"00", rst_event + delay_5m * 2 + cmd_delay * 11, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                
                -- Activating DM9000 on by enabling interrupts
                IO_WRITE_DATA(IMR, 16X"81", rst_event + delay_5m * 2 + cmd_delay * 12, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                
                -- Enable RX (RX enable, pass short packets, multicast disable, discard long packages (>1522 bytes) and packages with CRC Error)
                IO_WRITE_DATA(RCR, 16X"35", rst_event + delay_5m * 2 + cmd_delay * 13, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                
                if clk_count >= rst_event + delay_5m * 2 + cmd_delay * 14 then
                    rst_req <= '0';
                    rx_req  <= '1';
                end if;
             end if;
        

            if state = RX or ENET_INT = '1' then
                -- dummy read MRCMDX
                IO_READ_DATA(MRCMDX, data_int, rx_event + cmd_delay * 2, clk_count, ENET_WR_N, ENET_RD_N, ENET_CMD, ENET_tri, ENET_DATAo, ENET_DATA);
                -- Get the latest updated data from data bus
                IO_READ(data_int,  rx_event + cmd_delay * 3, clk_count, ENET_RD_N, ENET_CMD, ENET_tri, ENET_DATA);
-- TODO check and update if needed
                --RAM_WR   <= '1';
                --RAM_RST  <= '0';
                -- data_int byte must be 01 or 00 (01 - packet received, 00 - no packet in RX SRAM, others - software reset needed)
                if data_int(0) = '1' then
                    --reading
                    IO_SET_INDEX(X"F2", rx_event + cmd_delay * 4 + 2, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                    IO_READ(rx_status,  rx_event + cmd_delay * 5, clk_count, ENET_RD_N, ENET_CMD, ENET_tri, ENET_DATA);
                    IO_READ(rx_length,  rx_event + cmd_delay * 6, clk_count, ENET_RD_N, ENET_CMD, ENET_tri, ENET_DATA);
--                    rx_len_int <= to_integer(unsigned(rx_length))/2;
                    
                    --RAM_ADDR <= (RAM_ADDR + 1) / 12;
                    for i in 0 to rx_buf_len-1 loop
-- check this
                        --if rx_event + (i + 1 + 6) * cmd_delay = clk_count then
--                                end if;
--                                    exit; 
                        --exit when i >= (rx_len_int + 1);
--                                else
                            IO_READ(buf(i),  rx_event + (i + 1 + 6) * cmd_delay, clk_count, ENET_RD_N, ENET_CMD, ENET_tri, ENET_DATA);
                            
                        --end if;
                        --rx_buf(i) <= DATA_BUF(7 downto 0) & DATA_BUF(15 downto 8);
                    end loop;
-- Replace rx_buf_len with rx_len_int
                    IO_WRITE_DATA(ISR, 16X"01", rx_event + (rx_buf_len + 7) * cmd_delay, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);

-- Replace rx_buf_len with rx_len_int
                    if clk_count >= rx_event + (rx_buf_len + 8) * cmd_delay then
                        rx_req <= '0';
                        tx_req <= '1';
                        --RAM_ADDR <= 0;
                        rx_int   <= (others => '0');
                        data_int <= (others => '0');
                    end if;
                
                elsif data_int(1 downto 0) /= 2b"00" then
                    -- reset interrupt
                    IO_WRITE_DATA(IMR, 16X"80", rx_event + cmd_delay * 4, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                    -- reset ISR
                    IO_WRITE_DATA(ISR, 16X"0F", rx_event + cmd_delay * 5, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                    -- stop RX
                    IO_WRITE_DATA(RCR, 16X"00", rx_event + cmd_delay * 6, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                    
                    -- raise reset flag
                    if clk_count >= rx_event + cmd_delay * 7 then
                        rx_req <= '0';
                        rst_req <= '1';
                        rx_int   <= (others => '0');
                        data_int <= (others => '0');
                    end if;
                end if; 
            end if;

-- TODO comments
            if state = TX then
                --RAM_WR <= '0';
                IO_SET_INDEX(MWCMD, tx_event + cmd_delay * 0, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
--    -- check this
--    -- replace with tx_buf in future
                for i in 0 to rx_buf_len - 1 loop
                    --RAM_ADDR <= i;
                    IO_WRITE(buf(i), tx_event + (i + 1) * cmd_delay, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                end loop;
--    --check delays
                -- length of packet
                -- Maximum length is 1522 bytes so TXPLH is not used
                IO_WRITE_DATA(TXPLH, X"00" & rx_length(15 downto 8), tx_event + cmd_delay * (1 + rx_buf_len), clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                IO_WRITE_DATA(TXPLL, X"00" & rx_length(7 downto 0), tx_event + cmd_delay * (2 + rx_buf_len), clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                -- start transmission
                IO_WRITE_DATA(TCR,   16X"01", tx_event + cmd_delay * (3 + rx_buf_len), clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                
                if clk_count >= tx_event + cmd_delay * (4 + rx_buf_len) then
                    rx_req <= '1';
                    tx_req <= '0';
                    --RAM_RST <= '1';
                end if;
                    
            end if;
        end if;
    end process;
end architecture;