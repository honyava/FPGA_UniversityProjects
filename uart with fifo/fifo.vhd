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
        Q : out std_logic_vector(WIDTH-1 downto 0);
        
        --flags
        empty : out std_logic;
        full : out std_logic   
        );
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
    begin
        if rising_edge(CLK) then
            if CE = '1' then
                if CLR = '1' then
                    PTR_S <= 0;
                elsif WR = '1' and PTR_S < DEPTH-1 then
                    PTR_S <= PTR_S + 1;
                elsif WR = '1' and PTR_S >= DEPTH - 1 then
                    PTR_S <= 0;                    
                end if;
            end if;
        end if;
    end process;
    
    -- incrementing ptr to read from
    process (CLK)
    begin
        if rising_edge(CLK) then
            Q <= fifo_array(PTR_E) when RD = '1';
            if CE = '1' then
                if CLR = '1' then
                    PTR_E <= 0;
                elsif RD = '1' and PTR_E < DEPTH-1 then
                    PTR_E <= PTR_E + 1;
                elsif RD = '1' and  PTR_E >= DEPTH-1 then
                    PTR_E <= 0;
                end if;
            end if;
        end if;
    end process;
    
    -- flag empty
    process (CLK)
    begin
        if rising_edge(CLK) then
            if CE = '1' then
                if PTR_E >= DEPTH - 1 then
                    empty <= '1';
                else
                    empty <= '0';
                end if;
            end if;
        end if;
    end process;
    
    -- flag full
    process (CLK)
    begin
        if rising_edge(CLK) then
            if CE = '1' then
                if PTR_S >= DEPTH - 1 then
                    full <= '1';
                else
                    full <= '0';
                end if;
            end if;
        end if;
    end process;
    
    
end architecture;
