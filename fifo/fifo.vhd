library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity fifo is
    generic(
    DEPTH : natural := 16;
    WIDTH : natural := 8
    );
    port(
        CE : in std_logic;
        CLR : in std_logic;
        CLK : in std_logic;
        RD : in std_logic;
        WR : in std_logic;
        DATA : in std_logic_vector(WIDTH-1 downto 0);
        Q : out std_logic_vector(WIDTH-1 downto 0));
end entity;


architecture fifo_arch of fifo is
    type fifo_array_type is array (DEPTH-1 downto 0) of std_logic_vector(WIDTH-1 downto 0);
    signal fifo_array : fifo_array_type;
    signal PTR_S : INTEGER range 0 to DEPTH-1; --pointer start(head)
    signal PTR_E : INTEGER range 0 to DEPTH-1; --pointer end 
begin
    -- writing into fifo
    process (CLK)
    begin
        if rising_edge(CLK) then
            if CE = '1' then
                if CLR = '1' then
                    for I in DEPTH-1 downto 0 loop
                        fifo_array(I) <= (others => '0');
                    end loop;
                elsif WR = '1' then
                    fifo_array(PTR_S) <= DATA;
                end if;
            end if;
        end if;
    end process;
    
    -- incrementing ptr to write into
    process (CLK)
        variable PTR_V : INTEGER range 0 to DEPTH;
    begin
        if rising_edge(CLK) then
            if CE = '1' then
                if CLR = '1' then
                    PTR_S <= 0;
                    PTR_V := 0;
                elsif WR = '1' and PTR_V < DEPTH then
                    if PTR_S < DEPTH-1 then
                        PTR_S <= PTR_S + 1;
                    end if;
                    PTR_V := PTR_V + 1;
                elsif RD = '1' and PTR_V > 0 then
                    if PTR_S > 0 then
                        PTR_S <= PTR_S - 1;
                    end if;
                    PTR_V := PTR_V - 1;
                end if;
            end if;
        end if;
    end process;
    
    -- incrementing ptr to read from
    process (CLK) 
        variable PTR_G : INTEGER range 0 to DEPTH;
    begin
        if rising_edge(CLK) then
            Q <= fifo_array(PTR_E) when RD = '1' else (others => '0');
            if CE = '1' then
                if CLR = '1' then
                    PTR_E <= 0;
                    PTR_G := 0;
                elsif RD = '1' and PTR_G < DEPTH then
                    if PTR_E < DEPTH-1 then
                        PTR_E <= PTR_E + 1;
                    end if;
                    PTR_G := PTR_G + 1;
                elsif RD = '1' and PTR_G > DEPTH then
                    if PTR_E > DEPTH-1 then
                        PTR_E <= 0;
                    end if;
                    PTR_G := 0;
                end if;
            end if;
        end if;
    end process;
    
    
end architecture;
