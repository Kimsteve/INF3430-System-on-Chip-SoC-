library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity p_ctrl is
  port(
    -- System Clock and Reset
    rst       : in  std_logic;           -- Reset
    clk       : in  std_logic;           -- Clock
    sp        : in  signed(7 downto 0);  -- Set Point
    pos      : in  signed(7 downto 0);  -- Measured position
    motor_cw  : out std_logic;           --Motor Clock Wise direction
    motor_ccw : out std_logic            --Motor Counter Clock Wise direction
    );      
end p_ctrl;

architecture p_ctrlArch of p_ctrl is

  type state_type is (idle_st, sampel_st, motor_st);
  signal current_state, next_state  : state_type;
  signal error    : signed(7 downto 0);
  signal sp_int  : signed(7 downto 0);
  signal pos_int  : signed(7 downto 0);


begin

 process(rst, clk) is
  begin
    if rst = '1' then
      pos_int <= "00000000";
			sp_int <= "00000000";
    elsif rising_edge(clk) then
      pos_int <= pos;
			sp_int <= sp;
    end if;
  end process; 

  process(clk, rst) is
  begin
    if rst = '1' then
      current_state <= idle_st;
    elsif (rising_edge(clk)) then
      current_state <= next_state; 
    end if;
  end process;

 process(sp_int, pos_int, current_state) is
  begin
    case current_state is
      when idle_st =>
        motor_cw <= '0';
        motor_ccw <= '0';
        next_state <= sampel_st;
      when sampel_st =>
        error <= (sp_int - pos_int);
        next_state <= motor_st;
      when motor_st =>
        if (error > "00000000") then
          motor_cw <= '1';
          motor_ccw <= '0';
        elsif (error < "00000000") then
          motor_cw <= '0';
          motor_ccw <= '1';
        else
          motor_cw <= '0';
          motor_ccw <= '0';
        end if;
        next_state <= sampel_st;
      when others =>
        next_state <= idle_st;
      end case;
  end process;
end architecture p_ctrlArch;