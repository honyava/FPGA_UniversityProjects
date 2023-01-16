library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity rtc is
    generic (
        CLK_FREQ : natural -- system clock frequency in hz
    );
    port (
        clk : in std_logic;
        rst : in std_logic;

        seconds : out natural := 0;
        minutes : out natural := 0;
        hours   : out natural := 0
    );
end entity rtc;

architecture rtl of rtc is
    signal ticks : integer;
begin

    process (clk, rst) is
        variable wrap : boolean;
    begin
        if rst then
            seconds <= 0;
            minutes <= 0;
            hours   <= 0;
            ticks   <= 0;
        elsif rising_edge(clk) then
            if ticks = CLK_FREQ then
                if seconds = 60 then
                    if minutes = 60 then
                        if hours = 24 then
                            hours <= 0;
                        else
                            hours <= hours + 1;
                        end if;
                        minutes <= 0;
                    else
                        minutes <= minutes + 1;
                    end if;
                    seconds <= 0;
                else
                    seconds <= seconds + 1;
                end if;
                ticks <= 0;
            else
                ticks <= ticks + 1;
            end if;
        end if;
    end process;

end architecture rtl;
