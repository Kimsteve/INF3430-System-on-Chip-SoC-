library IEEE, work;
use IEEE.Std_Logic_1164.all;

entity tristatebuffer is
	generic( width: integer := 15);
	port (
		en : in std_ulogic;
		inp : in std_logic_vector(width downto 0);
		tribus : out std_logic_vector(width downto 0)
	);

end entity;

architecture tristatebuffer_arch of tristatebuffer is

begin 
	--process(en, inp) is
		tribus <= inp when (en ='0') else (others => 'Z');
	--end process;
end tristatebuffer_arch;	
