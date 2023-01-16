library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.DM9000A_lib.all;

entity DM9000A_tx is
    port (
        clk        : in std_logic;
        clk_count  : in std_logic_vector(31 downto 0);
        tx_event   : in std_logic_vector(31 downto 0);
        rx_len_int : in natural;
        rx_req     : out std_logic;
        tx_req     : inout std_logic;
        
        RAM_ADDR  : out natural range 0 to 2**ADDR_WIDTH - 1;
        RAM_DATA  : out std_logic_vector((DATA_WIDTH-1) downto 0);
        RAM_WR    : out std_logic := '0';
        RAM_OUT   : in  std_logic_vector((DATA_WIDTH-1) downto 0);
        
        ENET_WR_N  : out   std_logic;
        ENET_CMD   : out   std_logic;
        ENET_DATAo : out std_logic_vector(15 downto 0);
        ENET_tri   : out std_logic
    );
end DM9000A_tx;

architecture rtl of DM9000A_tx is

begin
    process(clk)
    begin
        RAM_WR <= '0';
        if rising_edge(clk) then
---- TODO comments
            if tx_req = '1' then
--                IO_SET_INDEX(MWCMD, tx_event + cmd_delay * 0, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
--    -- check this
--    -- replace with tx_buf in future
--                for i in 0 to rx_buf_len - 1 loop
--                    IO_WRITE(rx_buf(i), tx_event + (i + 1) * cmd_delay, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
--                end loop;
--    --check delays
--                -- length of packet
--                -- Maximum length is 1522 bytes so TXPLH is not used
--                IO_WRITE_DATA(TXPLH, X"00" & rx_length(15 downto 8), tx_event + cmd_delay * (1 + rx_len_int), clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
--                IO_WRITE_DATA(TXPLL, X"00" & rx_length(7 downto 0), tx_event + cmd_delay * (2 + rx_len_int), clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
--                -- start transmission
--                IO_WRITE_DATA(TCR,   16X"01", tx_event + cmd_delay * (3 + rx_len_int), clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                
                if clk_count >= tx_event + cmd_delay * (4 + rx_len_int) then
                    rx_req <= '1';
                    tx_req <= '0';
                    --rx_buf <= (others => X"0");
                end if;
                    
            end if;
        end if;
    end process;
end architecture;