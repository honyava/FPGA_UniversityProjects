library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ATmega16_ALU is
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        -- SREG = I_T_H_S_V_N_Z_C
        -- I - Global Interrupt Enable (not used)
        -- T - Bit Copy Storage (not used)
        -- H - Half Carry Flag
        -- S - Sign Bit
        -- V - Two's Complement Overflow Flag
        -- N - Negative Flag
        -- Z - Zero Flag
        -- C - Carry Flag
        
        SREG : out std_logic_vector(7 downto 0)
    );
end ATmega16_ALU;

architecture rtl of ATmega16_ALU is 

    -- Programm memory for ATmega16
    type PROG_MEM_type is array (0 to 2**13 - 1) of std_logic_vector(15 downto 0);
    -- operation select (16 bits)
    -- 0 | input_a (5 bits)  | input_b (5 bits)  | output (5 bits)
    
    -- type codes
    -- sum (a+b)  - 0x00
    -- sub (a-b)  - 0x01
    -- mult (a*b) - 0x02
    -- inc a  - 0x03
    -- dec a  - 0x04

    -- General Purpose Registers for ATmega16
    type GP_Reg_type is array (0 to 2**5 -1) of signed(7 downto 0); 
    
    
    signal PROG_CNT : integer range 0 to 2**13 -1 := 0;

    constant PROG_MEM : PROG_MEM_type := (
        -- 0 " input_a | input_b  | output, operation select 
        16b"0_00000_00001_00010", 16x"00", -- r2  = r0 + r1   (-1 + -1 = -2)
        16b"0_01011_01100_01101", 16x"00", -- r13 = r11 + r12 (12 + 15 = 27)
        16b"0_00011_00100_00101", 16x"01", -- r5  = r3 - r4    (5 - 4 = 1
        16b"0_01110_01111_10000", 16x"01", -- r16  = r14 - r15 (15 - 16 = -1)
        16b"0_00110_00111_01000", 16x"02", -- r8  = r6 * r7 (7 * 8 = 56)
        16b"0_01010_11111_11111", 16x"03", -- r10 ++ (11++ = 12)
        16b"0_01010_11111_11111", 16x"04", -- r10 --(12-- = 11) 
        16b"0_10001_10010_10011", 16x"00", -- r19  = r17 + r18   (127 + 127)
    
        others => 16X"FFFF");

    signal GP_REG : GP_Reg_type := (
        8X"FF",  8X"FF", 8X"00", 8X"05",
        8X"04",  8X"00", 8X"07", 8X"08",
        8X"09",  8X"0A", 8X"00", 8X"0C",
        8X"0F",  8X"0E", 8X"0F", 8X"10",
        8X"11",  8X"7F", 8X"7F", 8X"14",
        8X"15",  8X"16", 8X"17", 8X"18",
        8X"19",  8X"1A", 8X"1B", 8X"1C",
        8X"1D",  8X"1E", 8X"1F", 8X"20",

        others => 8X"00");
begin
    CYCLE : process(clk)
        variable instr   : std_logic_vector(15 downto 0);
        variable addr    : std_logic_vector(15 downto 0);
        variable input_a : natural range 0 to 2**5-1;
        variable input_b : natural range 0 to 2**5-1;
        variable output  : natural range 0 to 2**5-1;
        
        variable Rd : signed(7 downto 0);
        variable Rr : signed(7 downto 0);
        variable R :  signed(7 downto 0);
        
        variable StatusREG : std_logic_vector(7 downto 0);
        
        variable mult_buf : signed(15 downto 0);
        
    begin
        if rising_edge(clk) then
            -- instruction word
            instr := PROG_MEM(PROG_CNT + 1);
            -- GPR address word
            addr  := PROG_MEM(PROG_CNT);
            
            input_a := to_integer(unsigned(addr(14 downto 10)));
            input_b := to_integer(unsigned(addr(9 downto 5)));
            output  := to_integer(unsigned(addr(4 downto 0)));
            
            Rd := GP_REG(input_a);
            Rr := GP_REG(input_b);
            
            -- Resetting program counter
            if PROG_CNT < 2**13 - 2 then
                PROG_CNT <= PROG_CNT + 2;
            else
                PROG_CNT <= 0;
            end if;
            
            -- variable SREG
            StatusREG := (others => '0');
            
            case instr is
                -- sum
                when 16x"00" =>
                    R := Rd + Rr;
                
                    StatusREG(5) := (Rd(3) and Rr(3)) or
                                (Rr(3) and (not R(3))) or
                                (Rd(3) and (not R(3)));
                    StatusREG(3) := (Rd(7) and Rr(7) and (not R(7))) or
                                ((not Rd(7)) and (not Rr(7)) and R(7));
                    StatusREG(2) := R(7);
                    StatusREG(4) := StatusREG(2) xor StatusREG(3);
                    
                    if R = X"00" then StatusREG(1) := '1'; else StatusREG(1) := '0'; end if;
                    --StatusREG(1) := '1' when  else '0';
                    StatusREG(0) := (Rd(7) and Rr(7)) or
                                (Rr(7) and (not R(7))) or
                                (Rd(7) and (not R(7)));
                                
                -- sub
                when 16x"01" =>
                    R := Rd - Rr;
                
                    StatusREG(5) := ((not Rd(3)) and Rr(3)) or
                                (Rr(3) and R(3)) or
                                ((not Rd(3)) and R(3));                         
                    StatusREG(3) := (Rd(7) and (not Rr(7)) and (not R(7))) or
                                ((not Rd(7)) and Rr(7) and R(7));
                    StatusREG(2) := R(7);
                    StatusREG(4) := StatusREG(2) xor StatusREG(3);
                    --StatusREG(1) := '1' when R = X"00" else '0';
                    if R = X"00" then StatusREG(1) := '1'; else StatusREG(1) := '0'; end if;
                    StatusREG(0) := ((not Rd(7)) and Rr(7)) or
                                (Rr(7) and R(7)) or
                                ((not Rd(7)) and R(7));
                                
                -- mult
                when 16x"02" =>
                    mult_buf := Rd * Rr;
                    R := mult_buf(7 downto 0);
                    GP_REG(output + 1) <= mult_buf(15 downto 8);
                    
                    --StatusREG(1) := '1' when R = X"00" else '0';
                    if R = X"00" then StatusREG(1) := '1'; else StatusREG(1) := '0'; end if;
                    StatusREG(0) := mult_buf(15);
                    
                -- inc
                when 16x"03" =>
                    output := input_a;
                    R := Rd + 8x"1"; 
                    
                    StatusREG(3) := R(7) and (not R(6)) and (not R(5)) and (not R(4)) and
                                (not R(3)) and (not R(2)) and (not R(1)) and (not R(0));  
                    StatusREG(2) := R(7); 
                    StatusREG(4) := StatusREG(2) xor StatusREG(3);
                    --StatusREG(1) := '1' when R = X"00" else '0';
                    if R = X"00" then StatusREG(1) := '1'; else StatusREG(1) := '0'; end if;

                -- dec
                when 16x"04" =>
                    output := input_a;
                    R := Rd - 8x"1";
                    
                    StatusREG(3) := not(R(7)) and R(6) and R(5) and R(4) and R(3) and R(2) and R(1) and R(0); 
                    StatusREG(2) := R(7);
                    StatusREG(4) := StatusREG(2) xor StatusREG(3);
                    --StatusREG(1) := '1' when R = X"00" else '0';
                    if R = X"00" then StatusREG(1) := '1'; else StatusREG(1) := '0'; end if;

                when others =>
                    null;
            end case;
            
            -- External reset
            if rst = '1' then 
                R := GP_REG(output);
                PROG_CNT <= 0;
                StatusREG := (others => '0');
            end if; 
            
            -- output
            SREG <= StatusREG;
            GP_REG(output) <= R;
        end if;
    end process;
end architecture;