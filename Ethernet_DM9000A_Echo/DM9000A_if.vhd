library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.DM9000A_lib.all;

entity DM9000A_if is 
    port (
        clk     : in std_logic;  
        
        LCD_EN       : out std_logic;
        LCD_RS       : out std_logic;
        LCD_RW       : out std_logic;
        LCD_DATA     : out std_logic_vector(7 downto 0);
        LCD_ON       : out std_logic;
        LCD_BLON     : out std_logic;
        
        ENET_RD_N : out   std_logic := '1';
        ENET_WR_N : out   std_logic := '1';
        ENET_CS_N : out   std_logic := '0';
        ENET_CMD  : out   std_logic;
        ENET_INT  : in    std_logic ;
        ENET_RESET_N : out std_logic := '1';
        ENET_CLK  : out   std_logic;
        ENET_DATA : inout std_logic_vector(15 downto 0)
    );        
    
end DM9000A_if; 


architecture rtl of DM9000A_if is 
   
    ---------------------------------------------------------------------------
    -- Ethernet package (ARP type) for transmitiing 
    ---------------------------------------------------------------------------
    -- All words are in little endian (this why PLEN and HLEN are swapped) 
    signal arp_response : std_logic_vector(335 downto 0) := dest_mac_addr & src_mac_addr &
            frame_type & HTYPE & PTYPE & PLEN & HLEN & ARP_oper & src_mac_addr &
            src_ip_addr & dest_mac_addr & dest_ip_addr;    

    ---------------------------------------------------------------------------
    -- Finite-state machine
    ---------------------------------------------------------------------------
    -- Register to hold the current state
    signal state : state_type := RESET;
    
    
    ---------------------------------------------------------------------------
    -- Interface signals (for buffer and ENET_CLK)
    ---------------------------------------------------------------------------
    
    -- Data output
    signal ENET_DATAo  : std_logic_vector(15 downto 0) := (others => '0');
    -- Switch data to tri-state
    signal ENET_tri    : std_logic                     := '0';  -- '1' = 'Z'
    -- Divided clock (25 MHz)
    signal clk25      : std_logic := '0';

    ---------------------------------------------------------------------------
    -- Counters
    ---------------------------------------------------------------------------

    -- Main clock ticks counter (used for serial execution) 
    signal clk_count  : std_logic_vector(31 downto 0) := (others => '0');
    -- Count clk ticks while state is RX (used for correct reading)
    signal rx_count   : natural := 0;
    -- Count clk ticks while state is TX (used for correct writing)
    signal tx_count   : natural := 0;
    -- clk_count value capture register (on rst_req rising edge)
    signal rst_event   : std_logic_vector(31 downto 0) := (others => '0');
    -- clk_count value capture register (on ENET_INT rising edge)
    signal tx_event   : std_logic_vector(31 downto 0) := (others => '0');
    -- clk_count value capture register (on ENET_INT falling edge)
    signal rx_event   : std_logic_vector(31 downto 0) := (others => '0');
    -- Software reset request flag
    signal rst_req    : std_logic := '1';
    -- TX request flag
    signal tx_req    : std_logic := '0';
    -- RX request flag
    signal rx_req    : std_logic := '0';
--    -- internal signal for synchronization SW0 with clk
--    signal int_SW0    : std_logic_vector (1 downto 0) := (others => '0');

    ---------------------------------------------------------------------------
    -- RX signals 
    ---------------------------------------------------------------------------

    -- Used for dummy reading
    signal read_data : std_logic_vector(15 downto 0) := (others => '1');
    -- Interrupt status word
    signal rx_int    : std_logic_vector(15 downto 0)    := (others => '0');
    -- Package status word
    signal data_int  : std_logic_vector(15 downto 0)  := (others => '0');
    -- RX status word
    signal rx_status : std_logic_vector(15 downto 0) := (others => '0');
    -- Length of RX package (in vector and integer)
    signal rx_length : std_logic_vector(15 downto 0) := (others => '0');
    signal rx_len_int : natural := 0; 
    
    ---------------------------------------------------------------------------
    -- RX package information 
    ---------------------------------------------------------------------------
    
    -- Destination (PC) MAC address read in RX state 
    signal dest_mac     : std_logic_vector(47 downto 0)  := (others => '0');
    -- Destination (PC) MAC address read from ARP package
    signal dest_ip      : std_logic_vector(31 downto 0)  := (others => '0');
    -- Ethernet frame typr (read in TX state)
    signal package_type : std_logic_vector(15 downto 0)  := (others => '0');
    
    ---------------------------------------------------------------------------
    -- Front detection
    ---------------------------------------------------------------------------
    
    -- Signals for rising edge detection and 
    --  generating single pulse on front of signal
    signal interrupt_rx  : std_logic_vector (1 downto 0) := (others => '0');
    signal tx_front_temp  : std_logic := '0';
    signal tx_front       : std_logic := '0';
    signal rx_front_temp  : std_logic := '0';
    signal rx_front       : std_logic := '0';
    signal rst_trig  : std_logic_vector (1 downto 0) := (others => '0');
    signal rst_front_temp : std_logic := '0';
    signal rst_front      : std_logic := '0';
    
    ---------------------------------------------------------------------------
    -- RAM interface signals
    ---------------------------------------------------------------------------
    
    signal RX_ADDR : natural range 0 to 2**ADDR_WIDTH - 1;
    signal RX_DATA : std_logic_vector((DATA_WIDTH-1) downto 0);
    signal RX_VALID   : std_logic := '0';
    signal RAM_RST  : std_logic := '0';
    signal RAM_OUT  : std_logic_vector((DATA_WIDTH -1) downto 0);
    --signal RAM_AUTO : std_logic := '0';
    
    ---------------------------------------------------------------------------
    -- LCD interface signals
    ---------------------------------------------------------------------------
    
    signal ip_out : std_logic_vector(31 downto 0) := (others => '0');
    
    --    signal DATA_BUF   : std_logic_vector(15 downto 0)  := (others => '0');
--    type memory_t is array(2**10-1 downto 0) of std_logic_vector(15 downto 0);
--    signal buf : memory_t; 


    -- Buffer for RX package
    -- 761 = 1522 / 2 (packages with length over 1522 bytes are discarded)
    -- replace 50 with 761 or with FIFO
--    constant rx_buf_len : natural := 32;
--    type rx_buf_t is array (0 to rx_buf_len-1) of std_logic_vector(15 downto 0); 
--    signal rx_buf : rx_buf_t;

begin
    
--    DM9000A : entity work.DM9000A
--    port map (
----        RX_ADDR   => RX_ADDR,
----        RX_DATA   => RX_DATA,
----        RX_VALID     => RX_VALID,
----        RAM_RST    => RAM_RST,
----        RAM_OUT    => RAM_OUT,
--        
--        state      => state,
--        
--        clk        => clk,
--        clk_count  => clk_count,
--        rst_req    => rst_req,
--        tx_req     => tx_req,
--        rx_req     => rx_req,
--        rst_event  => rst_event,
--        rx_event   => rx_event,
--        tx_event   => tx_event,
--        
--        ENET_INT   => ENET_INT ,
--        ENET_RD_N  => ENET_RD_N,
--        ENET_WR_N  => ENET_WR_N,
--        ENET_CMD   => ENET_CMD,
--        ENET_DATA  => ENET_DATA
--    );

    ---------------------------------------------------------------------------
    -- RAM module (single port)
    ---------------------------------------------------------------------------
    
    RAM : entity work.single_port_ram
    generic map (
        DATA_WIDTH => DATA_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH
    )
    port map (
        clk     => clk,
        addr    => RX_ADDR,
        data    => RX_DATA,
        --auto    => RAM_AUTO,
        --reset   => RAM_RST,
        we      => RX_VALID,
        q       => RAM_OUT
    );
    
    ---------------------------------------------------------------------------
    -- 1602 LCD interface module
    ---------------------------------------------------------------------------
    
    IP_DISP : entity work.IP_TO_LCD
    port map (
        clk          => clk,
        ip_addr_in  => ip_out,
        LCD_EN       => LCD_EN,
        LCD_RS       => LCD_RS,
        LCD_RW       => LCD_RW,
        LCD_DATA     => LCD_DATA,
        LCD_ON       => LCD_ON,
        LCD_BLON     => LCD_BLON
    );

    ---------------------------------------------------------------------------
    -- DM9000A' IP address indication
    ---------------------------------------------------------------------------
    
    LCD_IP : process(clk)
    begin
        -- LCD needs 60 ms to boot up
        -- 2DC6C0 = 3e6 ticks => 3e6 / 50e6 = 60 ms delay
        
        if rising_edge(clk) then
            if clk_count >= 32X"2DC6C0" then
            -- IP address is stored in little endian
            -- Converting it in big endian
                ip_out <= src_ip_addr(23 downto 16) & src_ip_addr(31 downto 24) 
                    & src_ip_addr(7 downto 0) & src_ip_addr(15 downto 8);
            end if;
        end if; 
    end process;

    ---------------------------------------------------------------------------
    -- Setting up signals
    ---------------------------------------------------------------------------

    -- Output to data bus and clock
    ENET_DATA <= ENET_DATAo when ENET_tri = '0' else (others => 'Z'); 
    ENET_CLK  <= clk25;
    
    arp_response <= dest_mac & src_mac_addr & frame_type &
                HTYPE & PTYPE & PLEN & HLEN & ARP_oper &
                src_mac_addr & src_ip_addr &
                dest_mac & dest_ip;
	 
    ---------------------------------------------------------------------------
    -- Clock division and edge detection
    ---------------------------------------------------------------------------
    
    DIV_clk: process (clk)
    begin 
        if rising_edge(clk) then
            
            -- Main counter
            clk_count  <= clk_count + 1;
            
            -- 25 MHz clock for DM9000A
            clk25 <= not clk25;
            ---------------
   -- T0DO Swap int_sw0 with other name     
--            int_SW0 <= int_SW0(0) & tx_req;
--            tx_front_temp <= int_SW0(1);
--            tx_front <= (not tx_front_temp and int_SW0(1));
-----------------
            -- Detecting ENET_INT rising edge for RX
            interrupt_rx <= interrupt_rx(0) & ENET_INT;
            rx_front_temp <= interrupt_rx(1);
            rx_front <= (not rx_front_temp and interrupt_rx(1));
            
            -- Detecting ENET_INT falling edge for TX
            tx_front <= (rx_front_temp and (not interrupt_rx(1)));
            
            -- Detecting rst_req rising edge for RX
            rst_trig <= rst_trig(0) & rst_req;
            rst_front_temp <= rst_trig(1);
            rst_front <= (not rst_front_temp and rst_trig(1));
            ----------------- 
-- TODO This should be done on front           
--            if rst_req = '1' then
--                clk_count <= (others => '0');
--            end if;
            
        end if;       
    end process;
    
    ---------------------------------------------------------------------------
    -- Main counter capture registers
    ---------------------------------------------------------------------------
    
    CAPT_cnt : process (clk)
    begin
        if rising_edge(clk) then
            -- Capture clk_count value on RESET event
            if rst_front = '1' then
                rst_event <= clk_count;
            end if; 
            
            -- Capture clk_count value on RX start
            if tx_front = '1' then
                tx_event <= clk_count;
            end if; 
            
            -- Capture clk_count value on TX start
            if rx_front = '1' then
                rx_event <= clk_count;
            end if;  
        end if;
    end process;
    
    ---------------------------------------------------------------------------
    -- Finite-state machine
    ---------------------------------------------------------------------------

    FSM : process (clk)
    begin
        if rising_edge(clk) then
            case state is
                when RESET =>
                    if rst_req = '0' then
                        state <= RX;
                    else
                        state <= RESET;
                    end if;
                when RX =>
                    if rst_req = '1' then
                        state <= RESET;
                    elsif tx_req = '1' then
                        state <= TX;
                    else
                        state <= RX;
                    end if;
                when TX =>
                    if rst_req = '1' then
                        state <= RESET;
                    elsif tx_req = '1' then
                        state <= TX;
                    else
                        state <= RX;
                    end if;
            end case;
        end if;
    end process;
    
    ---------------------------------------------------------------------------
    -- Process for handling states
    ---------------------------------------------------------------------------
    
    STATE_HANDLER : process(clk)
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
                
                -- Enable RX (RX enable, pass short packets, multicast enable, discard long packages (>1522 bytes) and packages with CRC Error)
                IO_WRITE_DATA(RCR, 16X"3D", rst_event + delay_5m * 2 + cmd_delay * 13, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                
                if clk_count >= rst_event + delay_5m * 2 + cmd_delay * 14 then
                    rst_req <= '0';
                    rx_req  <= '1';
                    rx_count <= 0;
                    tx_count <= 0;
                end if;
             end if;
        

            if state = RX and ENET_INT = '1' then
                -- incrementing RX count
                rx_count <= rx_count + 1;
                -- Setting RAM for writing
                RX_VALID <= '1';
                
                --check interrupt status in ISR
                IO_READ_DATA(ISR, rx_int, rx_event + cmd_delay * 1, clk_count, ENET_WR_N, ENET_RD_N, ENET_CMD, ENET_tri, ENET_DATAo, ENET_DATA);
                
                    -- if Packet Received bit set then check written data
                    if rx_int(0) = '1' then 
                        
                        -- dummy read MRCMDX
                        IO_READ_DATA(MRCMDX, read_data, rx_event + cmd_delay * 2, clk_count, ENET_WR_N, ENET_RD_N, ENET_CMD, ENET_tri, ENET_DATAo, ENET_DATA);
                        -- Get the latest updated data from data bus
                        IO_READ(data_int,  rx_event + cmd_delay * 3, clk_count, ENET_RD_N, ENET_CMD, ENET_tri, ENET_DATA);

                        -- this byte must be 01 or 00 (01 - packet received, 00 - no packet in RX SRAM, others - software reset needed)
                        if data_int(0) = '1' then
                            --reading status and length of the package
                            IO_SET_INDEX(X"F2", rx_event + cmd_delay * 4 + 2, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                            IO_READ(rx_status,  rx_event + cmd_delay * 5, clk_count, ENET_RD_N, ENET_CMD, ENET_tri, ENET_DATA);
                            IO_READ(rx_length,  rx_event + cmd_delay * 6, clk_count, ENET_RD_N, ENET_CMD, ENET_tri, ENET_DATA);
                            rx_len_int <= to_integer(unsigned(rx_length))/2;
                            
                            -- Incrementing RAM address
                            RX_ADDR <= rx_count / 12 - 6;
                            
                            -- Reading from data bus to RAM
                            if rx_count > 7 * cmd_delay and rx_count < (rx_len_int + 7) * cmd_delay then
                                IO_READ(RX_DATA,  rx_event + (rx_count / 12) * cmd_delay, clk_count, ENET_RD_N, ENET_CMD, ENET_tri, ENET_DATA);
                            end if;
                            
                            -- Otatining destination (PC) MAC and IP, protocol type 
                            case RX_ADDR is
                                when 0 + 1 =>
                                    dest_mac(47 downto 32) <= RX_DATA;
                                when 1 + 1 =>
                                    dest_mac(31 downto 16) <= RX_DATA;
                                when 2 + 1 =>
                                    dest_mac(15 downto 0)  <= RX_DATA;
                                when 7 + 1 =>
                                    package_type <= RX_DATA;
                                when 14 + 1 =>
                                    dest_ip(31 downto 16) <= RX_DATA; 
                                when 15 + 1 =>
                                    dest_ip(15 downto 0)  <= RX_DATA;
                                when others =>
                                    null;
                            end case;

                            
--                            if RX_ADDR = 0 then
--                                src_mac(23 downto 8) <= RX_DATA;
--                            elsif RX_ADDR = 1 then 
--                                src_mac(7 downto 0)   <= RX_DATA(15 downto 8);
--                                dest_mac(23 downto 16) <= RX_DATA(7 downto 0); 
--                            elsif RX_ADDR = 2 then 
--                                dest_mac(15 downto 0) <= RX_DATA; 
--                            end if;
--                           if clk_count = rx_event + (rx_len_int + 7) + 1 then
--                                RX_VALID <= '0'; 
--                                RX_ADDR <= 10X"00";
--                            elsif clk_count = rx_event + (rx_len_int + 7) + 2 then                           
--                            end if;

                            IO_WRITE_DATA(ISR, 16X"01", rx_event + (rx_len_int + 8) * cmd_delay, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);

--                            if clk_count >= rx_event + (rx_len_int + 8) * cmd_delay then
----                                rx_req <= '0';
----                                tx_count <= 0;
----                                --tx_req <= '1';
--                                rx_int   <= (others => '0');
--                                data_int <= (others => '0');
--                                rx_count <= 0;
--                            end if;

                        -- if status is not OK, then requesting software reset
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
            end if;
            
            -- Requesting TX on falling edge of ENET_INT
            if tx_front = '1' and rst_req = '0' then
                tx_req   <= '1';
                tx_count <= 0;
            end if;


            if state = TX then
                -- incrementing TX count
                tx_count <= tx_count + 1;
                -- Setting RAM for reading
                RX_VALID <= '0';
                
                -- Trigger MWCMD (memory data write with 
                --  autoincrementing pointer)
                IO_SET_INDEX(MWCMD, tx_event + cmd_delay * 1, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                
                -- Incrementing RAM address
                RX_ADDR <= tx_count / 12 -  1;
                
                -- Setting up delays for reading ("+2" accounts for needed 
                --  delay for index set, "-2" - we don't need to transmit checksum bytes
                if tx_count > 2 * cmd_delay and tx_count < (rx_len_int + 2 - 1) * cmd_delay and package_type /= X"0608" then
                    IO_WRITE(RAM_OUT, tx_event + (tx_count / 12) * cmd_delay + 2, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                elsif package_type = X"0608" then
                    -- if we receive ARP package then send ARP response 
                    for i in 20 downto 0 loop
                        IO_WRITE(arp_response(16 * (i + 1) - 1 downto 16 * i), tx_event + (20 - i + 2) * cmd_delay, clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                        rx_length <= X"002A";
                    end loop;
                end if;
                
                -- Swapping destination and sender MAC
                case tx_count is
                    when 0 =>
                        RX_VALID <= '1';
                        RX_ADDR <= 0;
                        RX_DATA <= dest_mac(47 downto 32);
                        
                    when 1 =>
                        RX_VALID <= '1';
                        RX_ADDR <= 1;
                        RX_DATA <= dest_mac(47 downto 32);
                        
                    when 2 =>
                        RX_VALID <= '1';
                        RX_ADDR <= 2;
                        RX_DATA <= dest_mac(31 downto 16);
                        
                    when 3 =>
                        RX_VALID <= '1';
                        RX_ADDR <= 3;
                        RX_DATA <= dest_mac(15 downto 0);
                        
                    when 4 =>
                        RX_VALID <= '1';
                        RX_ADDR <= 4;
                        RX_DATA <= src_mac_addr(47 downto 32); 
                        
                    when 5 =>
                        RX_VALID <= '1';
                        RX_ADDR <= 5;
                        RX_DATA <= src_mac_addr(31 downto 16);
                        
                    when 6 =>
                        RX_VALID <= '1';
                        RX_ADDR <= 6;
                        RX_DATA <= src_mac_addr(15 downto 0);
                        
                    when 7 =>                   
                        RX_VALID <= '1';
                        RX_ADDR <= 6;
                        RX_DATA <= src_mac_addr(15 downto 0);  
                        
                    when others =>
                        null;
                end case; 
        
                -- Writing length of TX package in DM9000A
                IO_WRITE_DATA(TXPLH, X"00" & rx_length(15 downto 8), tx_event + cmd_delay * (3 + rx_len_int), clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                IO_WRITE_DATA(TXPLL, X"00" & (rx_length(7 downto 0) - 4), tx_event + cmd_delay * (4 + rx_len_int), clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                -- start transmission
                IO_WRITE_DATA(TCR,   16X"01", tx_event + cmd_delay * (5 + rx_len_int), clk_count, ENET_WR_N, ENET_CMD, ENET_tri, ENET_DATAo);
                
                if clk_count >= tx_event + cmd_delay * (6 + rx_len_int) then
                    rx_req <= '1';
                    tx_req <= '0';
                    rx_count <= 0;
                end if;
                    
            end if;
        end if;
    end process;
end rtl;