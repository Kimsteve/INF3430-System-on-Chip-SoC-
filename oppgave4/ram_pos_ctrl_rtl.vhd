library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

architecture ram_pos_ctrl_o4_rtl of ram_pos_ctrl is

	component system_stub is
	port (
    fpga_0_RS232_RX_pin : in std_logic;
    fpga_0_RS232_TX_pin : out std_logic;
    fpga_0_LEDs_8Bit_GPIO_IO_O_pin : out std_logic_vector(0 to 7);
    fpga_0_Push_Buttons_3Bit_GPIO_IO_I_pin : in std_logic_vector(0 to 2);
    fpga_0_clk_1_sys_clk_pin : in std_logic;
    fpga_0_rst_1_sys_rst_pin : in std_logic
  );
	end component;
  
    component ram_sp is
	port
    (
      clk : in std_logic;               --Klokke
      rst : in std_logic;               --Asynkron rst

      --ram interface
      adr      : out std_logic_vector(17 downto 0);  --Adresse
      d_in     : in  std_logic_vector(15 downto 0);  --Data fra SRAM
      d_out    : out std_logic_vector(15 downto 0);  --Data til SRAM
      cs_ram_n : out std_logic;         --Chip select RAM
      we_ram_n : out std_logic;         --We enable strobe
      oe_ram_n : out std_logic;  --Output enable (enabler SRAMs tristate utganger)
      lb_ram_n : out std_logic;         --Velger ut lav byte (LSB)
      ub_ram_n : out std_logic;         --Velger ut høy byte (MSB)

      -- Load run sp inteeface
      load_run_sp    : in  std_logic;  --Signal fra trykknappen BTN2 for å lagre/spille av et setpoint
      load_sp_mode   : in  std_logic;   --SW7 place state machine in load mode
      sp_in          : in  std_logic_vector(6 downto 0);
      sp_out         : out std_logic_vector(7 downto 0);
      chip_scope_out : out std_logic_vector(31 downto 0)  --Kan benyttes til å koble til Chip_scope ILA module
      );
    end component;
  
	  component pos_seg7_ctrl is
	  port (
		-- System Clock and Reset
		rst         : in  std_logic;       -- Reset
		rst_div  : std_logic;
		mclk     : std_logic;
		mclk_div : std_logic;
		sync_rst     : in  std_logic;       -- Synchronous reset 
		sp           : in  std_logic_vector(7 downto 0);  -- Set Point
		a            : in  std_logic;       -- From position sensor
		b            : in  std_logic;       -- From position sensor
		force_cw     : in  std_logic;       -- Force motor clock wise motion
		force_ccw    : in  std_logic;       -- Force motor counter clock wise motion
		motor_cw     : out std_logic;       -- Motor clock wise motion
		motor_ccw    : out std_logic;       -- Motor counter clock wise motion
		-- display
		abcdefgdec_n : out std_logic_vector(6 downto 0);
		a_n          : out std_logic_vector(3 downto 0)
		);
	 end component;


	  component cru is
	  port (
		arst      : in std_logic; -- Asynch. reset
		refclk    : in std_logic; -- Reference clock
		rst       : out std_logic; -- Synchronized arst_n for mclk
		rst_div   : out std_logic; -- Synchronized arst_n for mclk_div
		mclk      : out std_logic; -- Master clock
		mclk_div  : out std_logic -- Master clock div. by 128.
	  );
	  end component;
		
		component tristatebuffer is
		generic( width: integer );
		port (
			en : in std_ulogic;
			inp : in std_logic_vector(width downto 0);
			tribus : out std_logic_vector(width downto 0)
		);
		end component;

    signal sp_o_internal       :   std_logic_vector(7 downto 0);
	 signal mclk_int     : std_logic;
    signal mclk_div_int : std_logic;
    signal rst_int      : std_logic;
    signal rst_div_int  : std_logic;
	 signal sync_rst_int  : std_logic :='0';
	 signal dq_internal_out       :  std_logic_vector(15 downto 0);
	 signal dq_internal_in       :  std_logic_vector(15 downto 0);
	 signal chip_scope_internal       :  std_logic_vector(31 downto 0);
	 signal we_ram_internal       :  std_logic;
	
	signal btn_p_internal : std_logic_vector(0 to 2);
	signal led_out_internal : std_logic_vector(0 to 7);
	signal sp_mux_sel    : std_logic;
	signal sp_ctrl : std_logic_vector(7 downto 0);

begin
	leds_out	<= led_out_internal;
	dq_internal_in <= dq;
	we_ram_n <= we_ram_internal; 
	
	system_stub_ram_pos : 	 system_stub 
			port map (
			fpga_0_RS232_RX_pin =>  RS232RX_pin,
			fpga_0_RS232_TX_pin =>  RS232TX_pin,
			fpga_0_LEDs_8Bit_GPIO_IO_O_pin => led_out_internal,
			fpga_0_Push_Buttons_3Bit_GPIO_IO_I_pin =>  btn_p_internal,
			fpga_0_clk_1_sys_clk_pin => refclk,
			fpga_0_rst_1_sys_rst_pin => arst
			);
			
	
	
    cru_ram_pos: cru port map(
                    arst=> arst, 
                    refclk=>refclk, 
                    rst=> rst_int, 
                    rst_div=> rst_div_int, 
                    mclk=>mclk_int, 
                    mclk_div=>mclk_div_int
                    ); 
					
	
    pos_seg7_ctrl_ram_pos:  pos_seg7_ctrl 
		  port map (
		   
					rst=> rst_int,    
					rst_div=>rst_div_int, 
					mclk=>mclk_int,     
					mclk_div=> mclk_div_int, 
					sync_rst=>sync_rst_int,   
					sp=>sp_ctrl,         
					a=>a,         
					b=>b,           
					force_cw=>force_cw, 
					force_ccw=>force_ccw,
					motor_cw=>motor_cw,  
					motor_ccw=>motor_ccw,    
					-- display
					abcdefgdec_n =>abcdefgdec_n,
					a_n=>a_n   
			);
		 
	ram_sp_ram_pos: ram_sp 
			port map
			(
					  clk=>mclk_int, 
					  rst => rst_int,
					  --ram interface
					  adr =>adr,     
					  d_in =>dq_internal_in,    
					  d_out=>dq_internal_out,	  
					  cs_ram_n=> cs_ram_n,
					  we_ram_n =>we_ram_internal,
					  oe_ram_n =>oe_ram_n,
					  lb_ram_n =>lb_ram_n,
					  ub_ram_n =>ub_ram_n,
					  -- Load run sp inteeface
					  load_run_sp=>load_run_sp, 
					  load_sp_mode =>sw7(7),
					  sp_in=> sw7(6 downto 0),      
					  sp_out=>sp_o_internal,      
					  chip_scope_out=>chip_scope_internal 
			  );
    	 
	tristatebuffer_t:  tristatebuffer 
		generic map(15)
			port map (
				en=>we_ram_internal,
				inp=>dq_internal_out, 
				tribus=>dq
			);
			
  process(sw7(7), sw7(6)) is
	begin
		--values from RAM with use of BTN2
		if(sw7(7) = '0' and sw7(6) = '1') then  
			sp_mux_sel <= '1';
			btn_p_internal(2) <= force_ccw;
			btn_p_internal(1) <= force_cw;
			btn_p_internal(0) <= load_run_sp;
      --values from the MicroBlaze with use of BTN2
		elsif (sw7(7) = '0' and sw7(6) = '0') then
			sp_mux_sel <= '0';
			btn_p_internal <= "ZZZ";

		else
			sp_mux_sel <= 'Z';
		end if;
  end process;
  
  process(sp_mux_sel) is
  begin
    case sp_mux_sel is
      when '1' =>
        sp_ctrl(0) <= led_out_internal(7);
        sp_ctrl(1) <= led_out_internal(6);
        sp_ctrl(2) <= led_out_internal(5);
        sp_ctrl(3) <= led_out_internal(4);
        sp_ctrl(4) <= led_out_internal(3);
        sp_ctrl(5) <= led_out_internal(2);
        sp_ctrl(6) <= led_out_internal(1);
        sp_ctrl(7) <= led_out_internal(0);
      when '0' =>
        sp_ctrl <= sp_o_internal;
      when others =>
        sp_ctrl <= "ZZZZZZZZ";
    end case;
  end process ;

end ram_pos_ctrl_o4_rtl;

