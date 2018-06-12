library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity seg7_ctrl is
	port
	(

	mclk : in std_logic;
	reset : in std_logic;
	d0 : in std_logic_vector(3 downto 0);
	d1 : in std_logic_vector(3 downto 0);
	d2 : in std_logic_vector(3 downto 0);
	d3 : in std_logic_vector(3 downto 0);
	--dec : in std_logic_vector(3 downto 0);
	--dec : in std_logic;
	abcdefgdec_n: out std_logic_vector(6 downto 0);
	a_n : out std_logic_vector(3 downto 0)

	);
end entity seg7_ctrl;

architecture mux7seg of seg7_ctrl is

signal sg: std_logic_vector(1 downto 0); --multiplexter
signal digit: std_logic_vector(3 downto 0); --output of multiplexter
signal enb: std_logic_vector(3 downto 0); -- enable four digit
signal div: std_logic_vector(20 downto 0); --counter 

begin 
sg<= div(18 downto 17); --top 2 bit 
enb <= "1111";
--dec <= '1';

process(sg, d0, d1, d2, d3)
--process(sg)
 begin 
	case sg IS
		WHEN "00" => digit <= d0;
		WHEN "01" => digit <= d1;
		WHEN "10" => digit <= d2;
		WHEN others => digit <= d3;
	end case;
end process;
	
	process(digit) 
		begin 
		case digit is 
		  when "0000" =>abcdefgdec_n<= "0000001"; --0
		  when "0001" =>abcdefgdec_n<= "1001111"; --1
		  when "0010" =>abcdefgdec_n<= "0010010"; --2
		  when "0011" =>abcdefgdec_n<= "0000110"; --3
		  when "0100" =>abcdefgdec_n<= "1001100"; --4  
		  when "0101" =>abcdefgdec_n<= "0100100";--5
		  when "0110" =>abcdefgdec_n<= "0100000";--6
		  when "0111" =>abcdefgdec_n<= "0001111";--7
			
		  when "1000" =>abcdefgdec_n<= "0000000";--8
		  when "1001" =>abcdefgdec_n<= "0001100";--9
		  when "1010" =>abcdefgdec_n<= "0001000";--A
		  when "1011" =>abcdefgdec_n<= "1100000";--B
		  when "1100" =>abcdefgdec_n<= "0110001";--C
		  when "1101" =>abcdefgdec_n<= "1000010";--D 
		  when "1110" =>abcdefgdec_n<= "0110000";--E
		  when "1111" =>abcdefgdec_n<= "0111000";--F
		  when OTHERS =>abcdefgdec_n<= "1111111"; --OTHERS
	end case;
	end process;
	
	--digit select an
	process(sg, enb)
		begin
			a_n <= "1111";
		if enb(conv_integer(sg)) = '1' then
			a_n(conv_integer(sg)) <= '0';
		end if;
	end process;
	
	--clock 
	process(mclk, reset)
	begin
		if reset = '1' then
			div <= (others => '0');
		elsif mclk'event and mclk = '1' then --rising edge of the clock.
			div <=div +1;
		end if;
	end process;
	
	
end mux7seg;

