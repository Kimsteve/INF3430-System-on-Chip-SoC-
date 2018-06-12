library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_debounce is 
end entity tb_debounce;



architecture debounce_arch of tb_debounce is

	component debouncer is

		port (
			rst       : in  std_logic;
			clk       : in  std_logic;
			bounced   : in  std_logic;
			debounced : out std_logic
			);
	end component;
	signal rst   : std_logic :='0';
	signal bounced  : std_logic := '0';
	signal debounced   : std_logic;
	signal clk            : std_logic :='0';
	constant Half_Period  : time := 50 ns;
	
	begin
		uut1: debouncer
		port map (
		rst => rst,
		clk => clk,
		bounced=>bounced,
		debounced=> debounced
		);
	clk <= not clk after Half_Period;

	process 
		begin
			rst<='1';
			wait for 200 ns;
			rst <= '0';
			wait for 100 ns;
			bounced <= '1', '0' after 200 ns;
			wait for 400 ns;
			bounced <= '1', '0' after 200 ns;
			
			wait;
	end process;		
end architecture debounce_arch;