library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.DM9000A_lib.all;

entity DM9000A_rx is
    port (
        clk       : in std_logic;
        clk_count : in std_logic_vector(31 downto 0);
        rx_event  : in std_logic_vector(31 downto 0);
        state     : in state_type;
        rst_req   : out std_logic;            
        rx_req    : out std_logic;
        tx_req    : out std_logic;
        
        RAM_ADDR  : out natural range 0 to 2**ADDR_WIDTH - 1;
        RAM_DATA  : out std_logic_vector((DATA_WIDTH-1) downto 0);
        RAM_WR    : out std_logic := '0';
        
        ENET_INT   : in    std_logic;
        ENET_RD_N  : out   std_logic;
        ENET_WR_N  : out   std_logic;
        ENET_CMD   : out   std_logic;
        ENET_DATA  : in std_logic_vector(15 downto 0);
        ENET_DATAo : out std_logic_vector(15 downto 0);
        ENET_tri   : out std_logic
    );
end DM9000A_rx;

architecture rtl of DM9000A_rx is
    signal data_int  : std_logic_vector(15 downto 0) := (others => '0');
    signal rx_status : std_logic_vector(15 downto 0) := (others => '0');
    signal rx_length : std_logic_vector(15 downto 0) := (others => '0');
    signal rx_int    : std_logic_vector(15 downto 0) := (others => '0');
    signal read_data : std_logic_vector(15 downto 0) := (others => '0');
    -- Length of received package
    signal rx_len_int : natural := 0; 
    
    constant rx_buf_len : natural := 32;
begin    
    process(clk)
    begin
        if rising_edge(clk) then
            if state = RX and ENET_INT = '1' then
                RAM_WR <= '1';
            
                --check interrupt status in ISR
                IO_READ_DATA(ISR, rx_int, rx_event + cmd_delay * 1, clk_count, ENET_WR_N, ENET_RD_N, ENET_CMD, ENET_tri, ENET_DATAo, ENET_DATA);
                    -- if Packet Received bit set then check written data
    -- TODO probably useful (check and delete if it is)
                    if rx_int(0) = '1' then 
                        -- dummy read MRCMDX
                        IO_READ_DATA(MRCMDX, read_data, rx_event + cmd_delay * 2, clk_count, ENET_WR_N, ENET_RD_N, ENET_CMD, ENET_tri, ENET_DATAo, ENET_DATA);
                        -- Get the latest updated data from data bus
                        IO_READ(data_int,  rx_event + cmd_delay * 3, clk_count, ENET_RD_N, ENET_CMD, ENET_tri, ENET_DATA);
    -- TODO check and update if needed
                        -- this byte must be 01 or 00 (01 - packet received, 00 - no packet in RX SRAM, others - software reset needed)
                        if data_int(0) = '1' then
                            --reading
                            IO_SET_INDEX(X"F2", rx_event + cmd_delay * 4 + 2, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                            IO_READ(rx_status,  rx_event + cmd_delay * 5, clk_count, ENET_RD_N, ENET_CMD, ENET_tri, ENET_DATA);
                            IO_READ(rx_length,  rx_event + cmd_delay * 6, clk_count, ENET_RD_N, ENET_CMD, ENET_tri, ENET_DATA);
                            rx_len_int <= to_integer(unsigned(rx_length))/2;

                            for i in 0 to rx_buf_len-1 loop
    -- check this   
                                --if rx_event + (i + 1 + 6) * cmd_delay = clk_count then
--                                end if;
--                                    exit; 
                                --exit when i >= (rx_len_int + 1);
--                                else
                                    IO_READ(read_data,  rx_event + (i + 1 + 6) * cmd_delay, clk_count, ENET_RD_N, ENET_CMD, ENET_tri, ENET_DATA);
                                    RAM_ADDR <= i;
                                    RAM_DATA <= read_data;
                                --end if;
                                --rx_buf(i) <= DATA_BUF(7 downto 0) & DATA_BUF(15 downto 8);
                            end loop;
-- Replace rx_buf_len with rx_len_int
                            IO_WRITE_DATA(ISR, 16X"01", rx_event + (rx_buf_len + 7) * cmd_delay, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);

-- Replace rx_buf_len with rx_len_int
                            if clk_count >= rx_event + (rx_buf_len + 8) * cmd_delay then                            
                                rx_req <= '0';
                                tx_req <= '1';
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
                            
                            -- raise reset req
                            if clk_count >= rx_event + cmd_delay * 7 then
                                RAM_WR   <= '0';
                                rx_req  <= '0';
                                --rst_req <= '1';
                                rx_int   <= (others => '0');
                                data_int <= (others => '0');
                            end if;
                        end if; 
                    end if;
            end if;
        end if;
    end process;
end architecture;