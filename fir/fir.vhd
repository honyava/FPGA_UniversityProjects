library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tools.all;

entity fir is
    generic (
        N : positive := 8;
        W : positive := 16        
        );	 
    port (
        clk   : in std_logic;
        din   : in signed(W - 1 downto 0);
        coeff : in signed_array_t(N - 1 downto 0)(W - 1 downto 0);
        dout  : out signed(W - 1 downto 0)
        );
end entity fir;

architecture rtl of fir is
    constant ACCUM_W : natural := 2 * W + log2(N);
    
    signal data_pipeline : signed_array_t(N - 1 downto 0)(W - 1 downto 0);
	 signal products : signed_array_t(N-1 downto 0)(N+W-2 downto 0);
	 signal first_sum : signed_array_t (N-1 downto 0)(ACCUM_W-1 downto 0);
begin
    
    process (clk) is
        variable accum : signed(ACCUM_W - 1 downto 0);
    begin
        if rising_edge(clk) then
            data_pipeline <= data_pipeline(N - 2 downto 0) & din;
            
            --accum := (others => '0');
				first_sum <= (others => '0');
            
            for i in 0 to N - 1 loop
                accum := accum + products(i);
            end loop;
				
            dout <= accum(accum'length - 1 downto accum'length - W);
        end if;
    end process;
    
	 product_calc : for i in 0 to N-1 generate
		products(i) <= resize(data_pipeline(i) * coeff(i), N+W-1);
	 end generate;
	 
	 add_reg: for i in 1 to N generate
		add(0) <= first_sum;
		add(i) <= add(i-1) + products(i);
	 end generate;
    
end architecture;



configuration fir_conf of fir is
    for rtl
    end for;
end configuration fir_conf;
