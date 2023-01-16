library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity single_port_ram_tb is
end single_port_ram_tb;

architecture sim of single_port_ram_tb is

    constant clk_hz : integer := 50e6;
    constant clk_period : time := 1 sec / clk_hz;

    constant DATA_WIDTH_tb : natural := 16;
    constant ADDR_WIDTH_tb : natural := 10

    signal clk_tb : std_logic := '1';
    signal rst_tb : std_logic := '1';

    signal addr_tb : in natural range 0 to 2**ADDR_WIDTH_tb - 1;
    signal data_tb : in std_logic_vector((DATA_WIDTH_tb-1) downto 0);
    signal we_tb   : in std_logic := '1';
    signal q_tb    : out std_logic_vector((DATA_WIDTH_tb -1) downto 0)

begin

    clk_tb <= not clk_tb after clk_period / 2;

    DUT : entity work.single_port_ram(rtl)
    generic map(
        DATA_WIDTH => DATA_WIDTH_tb,
        ADDR_WIDTH => ADDR_WIDTH
    )

    port map 
    (
        clk     <= clk_tb,
        addr    <= addr_tb,
        data    <= data_tb,
        we      <= we_tb,
        q       <= q_tb
    );

    SEQUENCER_PROC : process
    begin
        we <= '1';
        wait for clk_period * 2;

        for i in 0 to 2**ADDR_WIDTH - 1 loop
            addr <= std_logic_vector(to_unsigned(i, 10));
            data <= std_logic_vector(to_unsigned(567, 16));
        end loop;

        we <= '0';
        wait for clk_period * 2;

        for i in 0 to 2**ADDR_WIDTH - 1 loop
            addr <= std_logic_vector(to_unsigned(i, 10));
        end loop;

        -- assert false
        --     report "Replace this with your test cases"
        --     severity failure;

        finish;
    end process;

end architecture;