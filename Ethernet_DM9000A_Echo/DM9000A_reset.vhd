library ieee;  
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.DM9000A_lib.all;

entity DM9000A_reset is
    generic (
        src_mac_addr : std_logic_vector(47 downto 0) := X"01606E11020F"
    );
    port (
        clk       : in std_logic;
        clk_count : in std_logic_vector(31 downto 0);
        rst_event : in std_logic_vector(31 downto 0);
        state     : in state_type;       
        rx_req    : out std_logic;
        rst_req   : out std_logic;
        
        ENET_WR_N  : out   std_logic;
        ENET_CMD   : out   std_logic;
        ENET_DATAo : out std_logic_vector(15 downto 0);
        ENET_tri   : out std_logic
    );
end DM9000A_reset;

architecture rtl of DM9000A_reset is

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
                
                -- DM9000A is ready for work, start RX loop
                if clk_count >= rst_event + delay_5m * 2 + cmd_delay * 14 then
                    rst_req <= '0';
                    rx_req  <= '1';
                end if;
            end if;
        end if;    
    end process;
end architecture;