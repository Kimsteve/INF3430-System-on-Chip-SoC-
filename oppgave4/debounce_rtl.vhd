library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

architecture debounce_rtl of debouncer is

--signals:
	type state_type is(begin_st, bounce_st, count_st);
	signal current_st: state_type;
	signal counter : unsigned(cwidth-1 downto 0);
begin
	process(clk, rst) is
	begin
		if rst = '1' then
			debounced <='0';
		elsif(rising_edge(clk)) then
			case current_st is 
				when begin_st =>
					counter <=(others=>'0');
					debounced<='0';
					current_st<=bounce_st;
				when bounce_st =>
					if bounced = '1' then
						current_st<=count_st;
						debounced <='1';
					else
						current_st<=begin_st;
					end if;
				when count_st=>
					debounced<='0';
					counter<=counter+1;
					if counter=(cwidth-1 downto 0 => '1' ) then 
						current_st<=begin_st;
					else
						current_st<=count_st;
					end if;	
						
				when others=>
					current_st<=begin_st;
			end case;
		end if;
	end process;
	
					
				
 -- debounced <= bounced;
  
end architecture debounce_rtl;
