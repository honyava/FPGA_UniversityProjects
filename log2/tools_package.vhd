package tools is
	function log2(value : integer) return integer;
end package tools; 

package body tools is
	
	function log2(value : integer) return integer is
        variable temp : integer := value ;
        variable n : integer := 0 ;
    begin
        while temp > 1 loop
            temp := temp / 2 ;
            n := n + 1 ;
        end loop ;
        if value > 2 ** n then
            return(n+1) ; 
        else
            return(n) ; 
        end if ;
    end function log2;
	
	
end package body tools;