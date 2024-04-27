library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rdonly_addrfilter is
    Generic ( RDWR_STARTADDR: unsigned(31 downto 0) := X"00000000";  -- default: All addresses writable
              MEMSIZE_LOG2: integer := 17 );                         -- 2^17=128K (Max choice in Block Automation)
    Port ( addr_in : in STD_LOGIC_VECTOR (0 to 31);
           wren_in : in STD_LOGIC_VECTOR (0 to 3);
           wren_out : out STD_LOGIC_VECTOR (3 downto 0));
end rdonly_addrfilter;

architecture archie of rdonly_addrfilter is

    signal addr_numeric : unsigned(31 downto 0);

begin

    addr_numeric(31 downto 0) <= unsigned(addr_in(0 to 31));  -- includes Big->Little Endian conversion
    
    wren_out(3 downto 0) <= wren_in(0 to 3)                   -- includes Big->Little Endian conversion
                            when( addr_numeric(MEMSIZE_LOG2-1 downto 0) >= RDWR_STARTADDR(MEMSIZE_LOG2-1 downto 0) )
                            else (others=>'0');
                            
end archie;
