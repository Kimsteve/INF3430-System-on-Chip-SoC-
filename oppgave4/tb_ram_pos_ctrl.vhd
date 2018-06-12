library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_ram_pos_ctrl is
end entity;

architecture tb_ram_pos_ctrl_arch of tb_ram_pos_ctrl is 
	component ram_pos_ctrl is
		port (
			refclk : in std_logic;              --Klokke
			arst   : in std_logic;              --Asynkron rst
			--ram interface
			adr      : out   std_logic_vector(17 downto 0);  --Adresse
			dq       : inout std_logic_vector(15 downto 0);
			cs_ram_n : out   std_logic;         --Chip select RAM
			we_ram_n : out   std_logic;         --We enable strobe
			oe_ram_n : out   std_logic;         --Output enable (enabler SRAMs tristate utganger)
			lb_ram_n : out   std_logic;         --Velger ut lav byte (LSB)
			ub_ram_n : out   std_logic;         --Velger ut høy byte (MSB)
			load_run_sp :    std_logic;
			--Position measurement
			a           : in std_logic;
			b           : in std_logic;
			-- Motor control
			force_cw  : in  std_logic;
			force_ccw : in  std_logic;
			motor_cw  : out std_logic;
			motor_ccw : out std_logic;
			sw7       : in  std_logic_vector(7 downto 0);
			-- Interface to seven segments
			abcdefgdec_n : out std_logic_vector(6 downto 0);
			a_n          : out std_logic_vector(3 downto 0)
		);
	end component ram_pos_ctrl;
	
	component motor
		port (
		  motor_cw  : in  std_logic;
		  motor_ccw : in  std_logic;
		  a         : out std_logic;
		  b         : out std_logic
		);      
    end component motor;
	
	
	
	component async_256kx16 is
	  generic
		(
		  ADDR_BITS : integer := 18;
		  DATA_BITS : integer := 16;
		  depth     : integer := 256*1024;

		  TimingInfo   : boolean   := true;
		  TimingChecks : std_logic := '1'
		  );
		  port
			(
			  nCE : in    std_logic;            -- Chip Enable
			  nWE : in    std_logic;            -- Write Enable
			  nOE : in    std_logic;            -- Output Enable
			  nUB : in    std_logic;            -- Byte Enable High
			  nLB : in    std_logic;            -- Byte Enable Low
			  A   : in    std_logic_vector(addr_bits-1 downto 0);  -- Address Inputs A
			  DQ  : inout std_logic_vector(DATA_BITS-1 downto 0) := (others => 'Z')  -- Read/Write Data
			  ); 
	end component async_256kx16;

     
		signal refclk :  std_logic :='0';             
		signal arst   :  std_logic:='0';              --Asynkron rst
		--ram interface
		signal adr_internal      :    std_logic_vector(17 downto 0);  
		signal dq_internal       :  std_logic_vector(15 downto 0);
		signal cs_ram_n_internal :    std_logic;         --Chip select RAM
		signal we_ram_n_internal :    std_logic;         --We enable strobe
		signal oe_ram_n_internal :    std_logic;         --Output enable (enabler SRAMs tristate utganger)
		signal lb_ram_n_internal :    std_logic;         --Velger ut lav byte (LSB)
		signal ub_ram_n_internal :    std_logic;         --Velger ut høy byte (MSB)
		signal load_run_sp :    std_logic:='0';
		--Position measurement
		signal a_internal           :  std_logic:='0';
		signal b_internal           :  std_logic:='0';
		-- Motor control
		signal force_cw  :   std_logic:='0';
		signal force_ccw :   std_logic:='0';
		signal motor_cw_internal  :  std_logic:='0';
		signal motor_ccw_internal :  std_logic:='0';
		signal sw7       :   std_logic_vector(7 downto 0);
		-- Interface to seven segments
		signal abcdefgdec_n :  std_logic_vector(6 downto 0);
		signal a_n          :  std_logic_vector(3 downto 0);
		constant Half_Period :time := 30 ns;
	
	   begin		
		
		uut1: ram_pos_ctrl 
					port map (
					refclk=>refclk,
					arst=>arst,   
					--ram interface
					adr=>adr_internal,     
					dq=>dq_internal,    
					cs_ram_n=>cs_ram_n_internal,
					we_ram_n=>we_ram_n_internal, 
					oe_ram_n=>oe_ram_n_internal, 
					lb_ram_n=>lb_ram_n_internal, 
					ub_ram_n=>ub_ram_n_internal,
					load_run_sp=>load_run_sp, 
					--Position measurement
					a=>a_internal,       
					b=>b_internal,         
					-- Motor control
					force_cw=>force_cw,
					force_ccw=>force_ccw,
					motor_cw =>motor_cw_internal, 
					motor_ccw=>motor_ccw_internal, 
					sw7=>sw7,     
					-- Interface to seven segments
					abcdefgdec_n=>abcdefgdec_n,
					a_n=>a_n         
				);
	
	
	 uut2: motor 
        port map(
         motor_cw=> motor_cw_internal, 
         motor_ccw=>  motor_ccw_internal, 
         a=> a_internal, 
         b=> b_internal
        );
		
	uut3: async_256kx16		port map
			(
			  nCE=> cs_ram_n_internal, 
			  nWE=> we_ram_n_internal, 
			  nOE=> oe_ram_n_internal, 
			  nUB=> ub_ram_n_internal, 
			  nLB =>lb_ram_n_internal,
			  A=> adr_internal,  
			  DQ=> dq_internal
			  ); 
		
        
  refclk <= not refclk after Half_Period;
  
  process
	begin
		arst <= '1';
		wait for 5 us;
		arst <='0';
		wait for 5 us;
		
		sw7 <= "10000101";
		wait for 5 us;
		load_run_sp<='1', '0' after 15 us;
		wait for 100 us;
		
		sw7 <= "10000111";
		wait for 5 us;
		load_run_sp<='1', '0' after 15 us;
		wait for 100 us;
		
		sw7 <= "10000110";
		wait for 5 us;
		load_run_sp<='1', '0' after 15 us;
		wait for 100 us;
		
		
		wait;
 end process;		
  
  
		


end architecture;