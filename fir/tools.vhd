library ieee;
    use ieee.numeric_std.all;

package tools is    
    type signed_array_t is array(natural range <>) of signed;
    function log2 (i : natural) return integer;
    
end package;

package body tools is
    function log2 (i : natural) return integer is
        variable temp : integer := i;
        variable ret_val : integer := 0;
    begin
        while temp > 1 loop
            ret_val := ret_val + 1;
            temp := temp / 2;
        end loop;
        return ret_val;
    end function;
end package body;
