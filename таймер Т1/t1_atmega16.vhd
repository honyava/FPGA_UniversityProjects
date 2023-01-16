library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity t1_atmega16 is
    generic (
        N : natural := 16
        );
    port (
        clk    : in std_logic;
        -- top    : in std_logic_vector(2 downto 0); 
        -- updown : in std_logic;
        
        ICP1 : in std_logic; -- external capture flag
        ACO  : in std_logic; -- analog comparison flag
        ACIC : in std_logic; -- multiplexer for choosing flag

        WGM  : in std_logic_vector(1 downto 0); -- Waveform Generation Mode select
        COM  : in std_logic_vector(1 downto 0); -- Compare Match Output Mode select
        OC1  : buffer std_logic := '0'; -- timer compare interrupt
        OCR1 : in std_logic_vector(N-1 downto 0); -- timer compare register
        
        OVF1     : out std_logic; -- timer overflow interrupt

        t1_capt  : out std_logic; -- capture register interrupt
        ICR1  : buffer std_logic_vector(N-1 downto 0) := (others => '0'); -- capture output

        tcnt1 : out std_logic_vector(N-1 downto 0)  -- counter register    
        );
end t1_atmega16;

architecture rtl of t1_atmega16 is
    signal ICP1_front : std_logic;
    signal ACO_front  : std_logic;
begin
    -- Rising edge detection for ICP signal
    ICP_POSEDGE : process(clk)
        variable int_sig : std_logic_vector(1 downto 0);
    begin    
        if rising_edge(clk) then
            int_sig := int_sig(0) & ICP1;
        end if;
    
        ICP1_front <= (not int_sig(1)) and int_sig(0);
    end process;
    
    
    
    -- Rising edge detection for ACO signal
    ACO_POSEDGE : process(clk)
        variable int_sig : std_logic_vector(1 downto 0);
    begin    
        if rising_edge(clk) then
            int_sig := int_sig(0) & ACO;
        end if;
    
        ACO_front <= (not int_sig(1)) and int_sig(0);
    end process;
    
    
    
    -- Counter T1 from ATmega16, compare register from
    CNT : process (clk)
        -- TOP and BOTTOM values
        variable MAX_VAL : natural := 2**N - 1;
        variable MIN_VAL : natural := 0;
        
        -- internal counter register
        variable int_reg : integer range 0 to 2**N-1 := 0;
        -- internal compare register
        variable int_OCR : integer range 0 to 2**N-1 := 0;
        -- count direction
        variable updown  : std_logic := '1';
        
        -- status flags
        variable TOP : std_logic := '0';
        variable BOT : std_logic := '0';
        variable CMP : std_logic := '0'; 
    begin
        if rising_edge(clk) then

            -- rising up status flags
            if int_reg >= MAX_VAL then
                TOP := '1';
                BOT := '0';
                CMP := '0';
            elsif int_reg <= MIN_VAL then 
                TOP := '0';
                BOT := '1';
                CMP := '0';
            elsif int_reg = int_OCR then
                TOP := '0';
                BOT := '0';
                CMP := '1';
            else
                TOP := '0';
                BOT := '0';
                CMP := '0';
            end if;
            
            -- TOP value for CTC mode is OCR1
            if WGM = "10" then
                MAX_VAL := int_OCR;
            else
                MAX_VAL := 2**N - 1;
            end if; 
            -- Update of OCR1 for Fast PWM on BOTTOM
            if BOT = '1' and  WGM = "11" then
                int_OCR := to_integer(unsigned(OCR1));
            end if;
            
            -- counting up
            if (updown = '1') then
                if int_reg >= MAX_VAL then
                    int_reg := MIN_VAL;
                    OVF1 <= '1';
                    
                    -- Update of OCR1 for phase-correct PWM on TOP
                    if WGM = "01" then 
                        int_OCR := to_integer(unsigned(OCR1)); 
                        -- overflow flag for phase-correct PWM on TOP sets only on BOTTOM
                        OVF1 <= '0';
                    end if;
                else
                    int_reg := int_reg + 1;
                    OVF1 <= '0';
                end if;
            -- counting down
            elsif (updown = '0') then
                if int_reg <= MIN_VAL then
                    int_reg := MAX_VAL;
 
                    if WGM = "01" then
                        OVF1 <= '1';
                    end if;
                else
                    int_reg := int_reg - 1;
                    OVF1 <= '0';
                end if;
            end if;
            
            
            -- Compare register 
            case WGM is
                when "00" =>
                -- Normal mode
                    int_OCR := to_integer(unsigned(OCR1));
                    updown := '1';
                    
                    case COM is
                        -- NC
                        when "00" => 
                        OC1 <= '0';
                        -- Toggle OC1 when CMP = '1'
                        when "01" => 
                        OC1 <= CMP xor OC1;
                        -- Reset OC1 when CMP = '1'
                        when "10" => 
                            if CMP = '1' then
                                OC1 <= '0';
                            elsif TOP = '1' then
                                OC1 <= '1';
                            end if;
                        -- Set OC1 when CMP = '1'
                        when "11" =>
                            if CMP = '1' then
                                OC1 <= '1';
                            elsif TOP = '1' then
                                OC1 <= '0';
                            end if;
                        when OTHERS => null;
                    end case;
                when "01" =>
                -- Phase correct PWM
                
                    -- Setting count mode
                    if TOP = '1' and int_reg = MIN_VAL then
                        updown := '0';
                        int_reg := MAX_VAL - 1;
                    elsif BOT = '1' and int_reg = MAX_VAL then
                        updown := '1';
                        int_reg := MIN_VAL + 1;
                    end if;

                    case COM is
                        -- NC
                        when "00" => 
                            OC1 <= '0';
                        -- Set OC1 when CMP = '1' on descend, reset when CMP = '1' on ascend
                        when "10" => 
                            if CMP = '1' and updown = '1' then
                                OC1 <= '0';
                            elsif CMP = '1' and updown = '0' then
                                OC1 <= '1';
                            end if;
                        -- Reset OC1 when CMP = '1' on descend, set when CMP = '1' on ascend
                        when "11" =>
                            if CMP = '1' and updown = '1' then
                                OC1 <= '1';
                            elsif CMP = '1' and updown = '0' then
                                OC1 <= '0';
                            end if;
                        when OTHERS => null; 
                    end case;
                when "10" =>
                -- CTC
                    int_OCR := to_integer(unsigned(OCR1));
                    updown := '1';

                    case COM is
                        when "00" => 
                            OC1 <= '0';
                        when "01" => 
                            OC1 <= TOP xor OC1;
                        when "10" => 
                            if TOP = '1' then
                                OC1 <= '0';
                            else
                                OC1 <= '1';
                            end if;
                        when "11" =>
                            if TOP = '1' then
                                OC1 <= '1';
                            else
                                OC1 <= '0';
                            end if;
                        when OTHERS => null;
                    end case;
                when "11" =>
                -- Fast PWM 
                    updown := '1';
                
                    case COM is
                        -- NC
                        when "00" => OC1 <= '0';
                        -- non-inverted mode
                        when "10" => 
                            if CMP = '1' then
                                OC1 <= '0';
                            elsif BOT = '1' then
                                OC1 <= '1';
                            end if;
                        -- inverted mode
                        when "11" =>
                            if CMP = '1' then
                                OC1 <= '1';
                            elsif BOT = '1' then
                                OC1 <= '0';
                            end if;
                        when OTHERS => null;
                    end case;   
                when OTHERS =>
                    null;
            end case; 
            
            -- Capture register
            -- Choosing capture trigger
            if ACIC = '1' and ACO_front = '1' then
                ICR1 <= std_logic_vector(to_unsigned(int_reg, N));
                t1_capt <= '1';
            elsif ACIC = '0' and ICP1_front = '1' then
                ICR1 <= std_logic_vector(to_unsigned(int_reg, N));
                t1_capt <= '1';
            else
                -- resetting flag
                t1_capt <= '0';
            end if;
            
            
--            -- sync reset
--            if rst = '1' then
--                int_reg := 0;
--            end if;
        end if;
        
        tcnt1 <= std_logic_vector(to_unsigned(int_reg, N));
    end process;
    
end architecture;