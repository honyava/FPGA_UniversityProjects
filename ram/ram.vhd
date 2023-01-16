-- Quartus II VHDL Template
-- Single port RAM with single read/write address 

library ieee;
use ieee.std_logic_1164.all;

entity single_port_ram is

    generic 
    (
        DATA_WIDTH : natural := 16;
        ADDR_WIDTH : natural := 10
    );

    port 
    (
        clk     : in std_logic;
        addr    : in natural range 0 to 2**ADDR_WIDTH - 1;
        data    : in std_logic_vector((DATA_WIDTH-1) downto 0);
        --auto    : in std_logic := '0';
        --reset   : in std_logic := '0';
        we      : in std_logic := '1';
        q       : out std_logic_vector((DATA_WIDTH -1) downto 0)
    );

end entity;

architecture rtl of single_port_ram is

    -- Build a 2-D array type for the RAM
    subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
    type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;

    -- Declare the RAM signal.  
    signal ram : memory_t;

    -- Register to hold the address 
    signal addr_reg : natural range 0 to 2**ADDR_WIDTH-1;
    
    -- Counter for autoincrementing address
    signal cnt_12 : natural;

begin

    process(clk)
    begin
        if(rising_edge(clk)) then
            if(we = '1') then
                ram(addr) <= data;
            end if;
--            
--            if reset = '1' then
--                ram <= (others => (others => '0'));
--            end if;
--            
--            if auto = '1' then
--                cnt_12 <= cnt_12 + 1;
--                if cnt_12 = 11 then
--                    addr   <= addr + 1;
--                    cnt_12 <= 0;
--                end if;
--            end if;

            -- Register the address for reading
            addr_reg <= addr;
        end if;
        
--        if reset = '1' then
--            ram <= (others => 16X"0");
--        end if;
    end process;

    q <= ram(addr_reg);

end rtl;
