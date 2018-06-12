library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity pos_meas is
  port (
    -- System Clock and Reset
    rst      : in  std_logic;           -- Reset
    clk      : in  std_logic;           -- Clock
    sync_rst : in  std_logic;           -- Sync reset
    a        : in  std_logic;           -- From position sensor
    b        : in  std_logic;           -- From position sensor
    pos      : out signed(7 downto 0)   -- Measured position
   -- inp        : in  std_logic;           -- From position sensor
   --inp1        : in  std_logic;  
    );      
end pos_meas;

architecture pos_measArchitecture of pos_meas is
	type state_type is(start_up_st, wait_a0_st, wait_a1_st, up_down_st, count_up_st, count_down_st);
	signal current_state : state_type;
	signal pos_int : signed (7 downto 0) :="ZZZZZZZZ";
	signal a_int : std_logic;
	signal b_int  : std_logic;
	
 begin 
 
	process(rst, clk) is 
	  begin
		if rst = '1' then
			a_int <= '0';
			b_int <= '0';
		elsif rising_edge(clk) then
			a_int<=a;
			b_int <= b;
		end if;
	end process;	

	
	process(rst, clk) is
	  begin
		if rst = '1' then
			current_state <= start_up_st;
		elsif rising_edge(clk) then	
		  if sync_rst ='1' then
		    current_state <= start_up_st;
			else 
			case current_state is 
				when start_up_st =>
					pos_int <= "00000000";
					if a_int = '1' then
						current_state <= wait_a0_st;
					else 
						current_state<= wait_a1_st;
					end if;	
				when wait_a0_st=>
					if a_int = '1' then
						current_state <= wait_a0_st;
					else 
						current_state<= up_down_st;
					end if;
				when wait_a1_st =>
					if a_int = '1' then
						current_state <= wait_a0_st;
					else 
						current_state<= wait_a1_st;
					end if;
				when up_down_st =>
					if b_int = '1' then
						current_state <= count_down_st;
					elsif b_int = '0' then
						current_state<= count_up_st;
						else
						current_state<= up_down_st;
					end if;
				when count_up_st =>
					pos_int <=(pos_int +1);
					if(pos_int = "01111111") then	
						pos_int <="01111111";
					end if;	
					current_state <= wait_a1_st;
				when count_down_st =>
					pos_int <=(pos_int -1);
					if(pos_int= "00000000") then	
						pos_int <="00000000";
					end if;	
					current_state <= wait_a1_st;
					
				when others =>
					current_state<= start_up_st;
			end case;
		end if;
		end if;
	end process;
	pos <= pos_int;
end architecture pos_measArchitecture; 	
					
						
			
			
