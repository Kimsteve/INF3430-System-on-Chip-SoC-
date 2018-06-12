library ieee;
use ieee.std_logic_1164.all;

entity pos_seg7_ctrl is
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
end pos_seg7_ctrl;

architecture pos_seg7_ctrl_arch of pos_seg7_ctrl is

--component cru is
  --port (
    --arst      : in std_logic; -- Asynch. reset
    --refclk    : in std_logic; -- Reference clock
    --rst       : out std_logic; -- Synchronized arst_n for mclk
    --rst_div   : out std_logic; -- Synchronized arst_n for mclk_div
   -- mclk      : out std_logic; -- Master clock
    --mclk_div  : out std_logic -- Master clock div. by 128.
  --);
--end component;

component pos_ctrl is
  port (
    -- System Clock and Reset
    rst       : in  std_logic;          
    rst_div   : in  std_logic;          
    mclk      : in  std_logic;
    mclk_div  : in  std_logic;          
    sync_rst  : in  std_logic;          
    sp        : in  std_logic_vector(7 downto 0);  
    a         : in  std_logic;          
    b         : in  std_logic;         
    pos      : out std_logic_vector(7 downto 0);
    force_cw  : in  std_logic;         
    force_ccw : in  std_logic;          
    motor_cw  : out std_logic;         
    motor_ccw : out std_logic         
    );      
end component;
component seg7_ctrl is
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
end component;
  

  signal posi_int     : std_logic_vector(7 downto 0);
  signal pos_one      : std_logic_vector(3 downto 0);
  signal pos_two      : std_logic_vector(3 downto 0);
  signal sp_one       : std_logic_vector(3 downto 0);
  signal sp_two       : std_logic_vector(3 downto 0);
  
  --signal mclk_int     : std_logic;
 --signal mclk_div_int : std_logic;
  --signal rst_int      : std_logic;
  --signal rst_div_int  : std_logic;
  
begin
  

         
 uut1:  pos_ctrl port map(
                         rst=>   rst, 
                         rst_div=>  rst_div, 
                         mclk=> mclk, 
                         mclk_div=>mclk_div, 
                         sync_rst=>sync_rst, 
                         sp=>sp, 
                         a=> a, 
                         b=> b,
                         pos=> posi_int, 
                         force_cw=>force_cw, 
                         force_ccw=>force_ccw,
                         motor_cw=> motor_cw, 
                         motor_ccw=> motor_ccw
                        );
                        
     --  uut: cru port map(
                     --arst=> arst, 
                     --refclk=>refclk, 
                     --rst=> rst_int, 
                     --rst_div=> rst_div_int, 
                     --mclk=>mclk_int, 
                   --  mclk_div=>mclk_div_int
                 --   );                    
                       
  	uut2: seg7_ctrl port map(
							mclk=>   mclk, 
							reset=>  rst, 
							d0=>  pos_one, 
							d1=>  pos_two, 
							d2=>  sp_one, 
							d3=>  sp_two, 
							abcdefgdec_n=>  abcdefgdec_n, 
							a_n=>  a_n
							);
                        
 

   process(posi_int, sp) is
  begin
    pos_one <= posi_int(3 downto 0);
    pos_two <= posi_int(7 downto 4);
	  sp_one <= sp(3 downto 0);
    sp_two <= sp(7 downto 4);
  end process;
             
end pos_seg7_ctrl_arch;
