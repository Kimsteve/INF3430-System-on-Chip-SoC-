library ieee;
use ieee.std_logic_1164.all;

entity motor is
  generic (
    phase90 : time := 2 us
    );
  port (
    motor_cw  : in  std_logic;
    motor_ccw : in  std_logic;
    a         : out std_logic;
    b         : out std_logic
    );      
end motor;
