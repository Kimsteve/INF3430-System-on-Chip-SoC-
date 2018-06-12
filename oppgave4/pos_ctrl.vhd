library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity pos_ctrl is
  port (
    -- System Clock and Reset
    rst       : in  std_logic;          -- Reset
    rst_div   : in  std_logic;          -- Reset
    mclk      : in  std_logic;          -- Clock
    mclk_div  : in  std_logic;          -- Clock to p_reg
    sync_rst  : in  std_logic;          -- Synchronous reset
    sp        : in  std_logic_vector(7 downto 0);  -- Setpoint (wanted position)
    a         : in  std_logic;          -- From position sensor
    b         : in  std_logic;          -- From position sensor
    pos      : out std_logic_vector(7 downto 0);  -- Measured Position
    force_cw  : in  std_logic;          -- Force motor clock wise motion
    force_ccw : in  std_logic;          -- Force motor counter clock wise motion
    motor_cw  : out std_logic;          -- Motor clock wise motion
    motor_ccw : out std_logic           -- Motor counter clock wise motion
    );      
end pos_ctrl;

architecture pos_ctrl_arch of pos_ctrl is




component pos_meas is
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
end component;

component p_ctrl is
  port(
    -- System Clock and Reset
    rst       : in  std_logic;           -- Reset
    clk       : in  std_logic;           -- Clock
    sp        : in  signed(7 downto 0);  -- Set Point
    pos      : in  signed(7 downto 0);  -- Measured position
    motor_cw  : out std_logic;           --Motor Clock Wise direction
    motor_ccw : out std_logic            --Motor Counter Clock Wise direction
    );      
end component;

  signal cw_int   : std_logic;
  signal ccw_int  : std_logic;
  signal sp_int   : signed(7 downto 0);
  signal pos_int  : signed(7 downto 0);


begin
  sp_int <= signed('0'&sp(6 downto 0));
  
  pos_meas_ch:  pos_meas port map
  				(    rst=>rst, 
                     clk=>mclk, 
                     sync_rst=>sync_rst, 
                     a=>a, 
                     b=>b, 
                     pos=> pos_int
                    );
  
  p_ctrl_ch:  p_ctrl port map
  					( rst=>rst, 
                     -- clk=>mclk_div, 
							 clk=>mclk, 
                      sp=>sp_int, 
                      pos=>pos_int, 
                      motor_cw=>cw_int, 
                      motor_ccw=>ccw_int
                    );
                    
  pos <= std_logic_vector(pos_int);
  
  
 process(force_cw, force_ccw, cw_int, ccw_int) is
   begin
      if (force_cw = '0' and force_ccw = '1') then
        motor_cw <= '0';
        motor_ccw <= '1';
      elsif (force_cw = '1' and force_ccw = '0') then
        motor_cw <= '1';
        motor_ccw <= '0';
      else
        motor_cw <= cw_int;
        motor_ccw <= ccw_int;
      end if;
  end process;
  
  
end architecture pos_ctrl_arch;
