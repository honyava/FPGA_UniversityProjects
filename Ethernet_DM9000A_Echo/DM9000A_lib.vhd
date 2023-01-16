library ieee;  
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package DM9000A_lib is
    ---------------------------------------------------------------------------
    -- Constants --------------------------------------------------------------
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- DM9000A registers
    ---------------------------------------------------------------------------
    constant NCR    : std_logic_vector(7 downto 0) := X"00"; -- Network Control Register
    constant NSR    : std_logic_vector(7 downto 0) := X"01"; -- Network Status Register
    constant TCR    : std_logic_vector(7 downto 0) := X"02"; -- TX Control register
    constant RCR    : std_logic_vector(7 downto 0) := X"05"; -- RX Control Register
    constant WCR    : std_logic_vector(7 downto 0) := X"0F"; -- Wake Up Control Register
    constant GPCR   : std_logic_vector(7 downto 0) := X"1E"; -- General Purpose Control Register
    constant GPR    : std_logic_vector(7 downto 0) := X"1F"; -- General Purpose Register
    constant TCR2   : std_logic_vector(7 downto 0) := X"2D"; -- TX Control Register 2
    constant MRCMDX : std_logic_vector(7 downto 0) := X"F0"; -- Memory Data Pre-Fetch Read Command Without Address Increment 
    constant MWCMD  : std_logic_vector(7 downto 0) := X"F8"; -- TX FIFO SRAM init
    constant MWRL   : std_logic_vector(7 downto 0) := X"FA"; -- Memory Data Write_ address Register Low Byte
    constant MWRH   : std_logic_vector(7 downto 0) := X"FB"; -- Memory Data Write _ address Register High Byte
    constant TXPLL  : std_logic_vector(7 downto 0) := X"FC"; -- TX Packet Length Low Byte Register
    constant TXPLH  : std_logic_vector(7 downto 0) := X"FD"; -- TX Packet Length High Byte Register
    constant ISR    : std_logic_vector(7 downto 0) := X"FE"; -- Interrupt Status Register
    constant IMR    : std_logic_vector(7 downto 0) := X"FF"; -- Interrupt Mask Register

    ---------------------------------------------------------------------------
    -- Delays
    ---------------------------------------------------------------------------
    constant cmd_delay : natural := 12;
    constant delay_5m  : natural := 250000; -- 250000 * 20 ns = 5 ms
    constant delay_20u : natural := 1000;   -- 1000 * 20 ns = 20 us 
    
    ---------------------------------------------------------------------------
    -- Ethernet fields 
    ---------------------------------------------------------------------------
    constant dest_mac_addr : std_logic_vector(47 downto 0) := X"000EC6FAA65D"; -- MAC address [PC]
    -- constant src_mac_addr  : std_logic_vector(47 downto 0) := X"01606E11020F"; -- MAC address [DM9000]
    constant src_mac_addr  : std_logic_vector(47 downto 0) := X"6001116E0F02"; -- MAC address [DM9000] (in little endian)
    constant frame_type    : std_logic_vector(15 downto 0) := X"0608";         -- Package type (EtherValue) [ARP] (in little endian)
    
    ---------------------------------------------------------------------------
    -- ARP fields (in little endian)
    ---------------------------------------------------------------------------
    constant HTYPE        : std_logic_vector(15 downto 0) := X"0100";          -- Hardware type [Ethernet]
    constant PTYPE        : std_logic_vector(15 downto 0) := X"0008";          -- Protocol type [IPv4]
    constant HLEN         : std_logic_vector(7 downto 0)  := X"06";            -- Hardware length [MAC length = 6 bytes]
    constant PLEN         : std_logic_vector(7 downto 0)  := X"04";            -- Protocol length [IPv4 length = 4 bytes]
    constant ARP_oper      : std_logic_vector(15 downto 0) := X"0200";         -- Operation code [1 - request, 2 - reply]
    constant src_ip_addr   : std_logic_vector(31 downto 0) := X"A8C00A01";     -- Sender hardware address [DM9000A's IPv4]
    constant dest_ip_addr  : std_logic_vector(31 downto 0) := X"A8C00101";     -- Target hardware address [PC's IPv4]

    ---------------------------------------------------------------------------
    -- RAM size (16 bytes x 1024 words)
    ---------------------------------------------------------------------------
    constant DATA_WIDTH : natural := 16;
    constant ADDR_WIDTH : natural := 10;
    
    ---------------------------------------------------------------------------
    -- Finite-state machine types ---------------------------------------------
    ---------------------------------------------------------------------------
    -- An enumerated type for the state machine
    type state_type is (RESET, RX, TX);
    
    
    
    
    ---------------------------------------------------------------------------
    -- Procedures -------------------------------------------------------------
    ---------------------------------------------------------------------------
    
    ---------------------------------------------------------------------------
    -- Select DM9000A register
    ---------------------------------------------------------------------------
    procedure IO_SET_INDEX (
        constant reg        : in  std_logic_vector(7 downto 0);
        constant clk_offset : in  std_logic_vector(31 downto 0);
        signal   clk_cnt    : in  std_logic_vector(31 downto 0);
        signal   DM_IOW_n   : out std_logic;
        signal   DM_CMD     : out std_logic;
        signal   DM_tri     : out std_logic;
        signal   DM_SDo     : out std_logic_vector(15 downto 0));

    ---------------------------------------------------------------------------
    -- Write data to DATA port (to selected register)
    ---------------------------------------------------------------------------
    procedure IO_WRITE (
            constant data       : in  std_logic_vector(15 downto 0);
            constant clk_offset : in  std_logic_vector(31 downto 0);
            signal   clk_cnt    : in  std_logic_vector(31 downto 0);
            signal   DM_IOW_n   : out std_logic;
            signal   DM_CMD     : out std_logic;
            signal   DM_tri     : out std_logic;
            signal   DM_SDo     : out std_logic_vector(15 downto 0));
    
    ---------------------------------------------------------------------------
    -- Read data from DATA port (from selected register)
    ---------------------------------------------------------------------------
    procedure IO_READ (
        signal   dout       : out std_logic_vector(15 downto 0);
        constant clk_offset : in  std_logic_vector(31 downto 0);
        signal   clk_cnt    : in  std_logic_vector(31 downto 0);
        signal   DM_IOR_n   : out std_logic;
        signal   DM_CMD     : out std_logic;
        signal   DM_tri     : out std_logic;
        signal   DM_SD      : in  std_logic_vector(15 downto 0));

    ---------------------------------------------------------------------------
    -- Select register and write data
    ---------------------------------------------------------------------------
    procedure IO_WRITE_DATA (
        constant reg        : in  std_logic_vector(7 downto 0);
        constant data       : in  std_logic_vector(15 downto 0);
        constant clk_offset : in  std_logic_vector(31 downto 0);
        signal   clk_cnt    : in  std_logic_vector(31 downto 0);
        signal   DM_IOW_n   : out std_logic;
        signal   DM_CMD     : out std_logic;
        signal   DM_tri     : out std_logic;
        signal   DM_SDo     : out std_logic_vector(15 downto 0));

    ---------------------------------------------------------------------------
    -- Select register and read its data
    ---------------------------------------------------------------------------
    procedure IO_READ_DATA (
        constant reg        : in  std_logic_vector(7 downto 0);
        signal   dout       : out std_logic_vector(15 downto 0);
        constant clk_offset : in  std_logic_vector(31 downto 0);
        signal   clk_cnt    : in  std_logic_vector(31 downto 0);
        signal   DM_IOW_n   : out std_logic;
        signal   DM_IOR_n   : out std_logic;
        signal   DM_CMD     : out std_logic;
        signal   DM_tri     : out std_logic;
        signal   DM_SDo     : out std_logic_vector(15 downto 0);
        signal   DM_SD      : in  std_logic_vector(15 downto 0));
    
end package;

package body DM9000A_lib is
    -- IO_SET_INDEX
    -- outb(IOaddr) from datasheet
    -- Select the register in DM9000A (CMD = '0')
    procedure IO_SET_INDEX (
        constant reg        : in  std_logic_vector(7 downto 0);
        constant clk_offset : in  std_logic_vector(31 downto 0);
        signal   clk_cnt    : in  std_logic_vector(31 downto 0);
        signal   DM_IOW_n   : out std_logic;
        signal   DM_CMD     : out std_logic;
        signal   DM_tri     : out std_logic;
        signal   DM_SDo     : out std_logic_vector(15 downto 0)) is
    begin  
        if clk_cnt = clk_offset then
            DM_IOW_n <= '0';
            DM_CMD   <= '0';
            DM_tri   <= '0';
            DM_SDo   <= X"00" & reg;
        elsif clk_cnt = clk_offset + 2 then
            DM_IOW_n <= '1';
        elsif clk_cnt = clk_offset + 3 then
            DM_tri   <= '1';
        end if;
    end IO_SET_INDEX;

  -- IO_WRITE
  -- outb(data, IOaddr + 4) from datasheet     
  -- Writes to DM9000A DATA register, i.e., address (CMD = '1')             
    procedure IO_WRITE (
        constant data       : in  std_logic_vector(15 downto 0);
        constant clk_offset : in  std_logic_vector(31 downto 0);
        signal   clk_cnt    : in  std_logic_vector(31 downto 0);
        signal   DM_IOW_n   : out std_logic;
        signal   DM_CMD     : out std_logic;
        signal   DM_tri     : out std_logic;
        signal   DM_SDo     : out std_logic_vector(15 downto 0)) is
    begin
        if clk_cnt = clk_offset then
            DM_CMD   <= '1';
            DM_IOW_n <= '0';
            DM_SDo   <= data;
            DM_tri   <= '0';
        elsif clk_cnt = clk_offset + 2 then
            DM_IOW_n <= '1';
        elsif clk_cnt = clk_offset + 3 then
            DM_tri   <= '1';
        end if;
    end IO_WRITE;

  -- IO_READ  
  -- inb(IOaddr + 4) from datasheet
  -- Reads from DM9000A DATA register, ie, address (CMD = '1')
  -- Result is written into 'dout' signal            
    procedure IO_READ (
        signal   dout       : out std_logic_vector(15 downto 0);
        constant clk_offset : in  std_logic_vector(31 downto 0);
        signal   clk_cnt    : in  std_logic_vector(31 downto 0);
        signal   DM_IOR_n   : out std_logic;
        signal   DM_CMD     : out std_logic;
        signal   DM_tri     : out std_logic;
        signal   DM_SD      : in  std_logic_vector(15 downto 0)) is
    begin  -- IO_READ
        if clk_cnt = clk_offset then
            DM_CMD   <= '1';
            DM_tri   <= '1';
            DM_IOR_n <= '0';
        elsif clk_cnt = clk_offset + 2 then
            dout     <= DM_SD;
            DM_IOR_n <= '1';
        end if;
    end IO_READ;

    -- IO_WRITE_DATA
    -- iow(reg, data) from datasheet
    -- Performs a write to INDEX reg, ie, sets address (CMD = '0')
    -- then writes to DATA (CMD = '1')
    procedure IO_WRITE_DATA (
        constant reg        : in  std_logic_vector(7 downto 0);
        constant data       : in  std_logic_vector(15 downto 0);
        constant clk_offset : in  std_logic_vector(31 downto 0);
        signal   clk_cnt    : in  std_logic_vector(31 downto 0);
        signal   DM_IOW_n   : out std_logic;
        signal   DM_CMD     : out std_logic;
        signal   DM_tri     : out std_logic;
        signal   DM_SDo     : out std_logic_vector(15 downto 0)) is
    begin  -- IO_WRITE_DATA         
        IO_SET_INDEX(reg, clk_offset, clk_cnt, DM_IOW_n, DM_CMD, DM_tri, DM_SDo);
        IO_WRITE(data, clk_offset+4, clk_cnt, DM_IOW_n, DM_CMD, DM_tri, DM_SDo);
    end IO_WRITE_DATA;

    -- IO_READ_DATA procedure.
    -- ior(reg) from datasheet
    -- Performs a write to INDEX reg, ie, sets address (CMD = '0')
    -- then performs a read from data (CMD = '1')  
    -- Result is written into 'dout' signal
    procedure IO_READ_DATA (
        constant reg        : in  std_logic_vector(7 downto 0);
        signal   dout       : out std_logic_vector(15 downto 0);
        constant clk_offset : in  std_logic_vector(31 downto 0);
        signal   clk_cnt    : in  std_logic_vector(31 downto 0);
        signal   DM_IOW_n   : out std_logic;
        signal   DM_IOR_n   : out std_logic;
        signal   DM_CMD     : out std_logic;
        signal   DM_tri     : out std_logic;
        signal   DM_SDo     : out std_logic_vector(15 downto 0);
        signal   DM_SD      : in  std_logic_vector(15 downto 0)) is
    begin  -- IO_READ_DATA
        IO_SET_INDEX(reg, clk_offset, clk_cnt, DM_IOW_n, DM_CMD, DM_tri, DM_SDo);
        IO_READ(dout, clk_offset+4, clk_cnt, DM_IOR_n, DM_CMD, DM_tri, DM_SD);
    end IO_READ_DATA;

end package body;