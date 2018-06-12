library ieee;
use ieee.std_logic_1164.all;
entity bufg is
    port (
      i : in std_logic;
      o : out std_logic);
	  
end entity;

architecture arch_bufg of bufg is
	begin
		o<=i;
end arch_bufg;