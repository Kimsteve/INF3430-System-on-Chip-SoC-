library IEEE;
use IEEE.std_logic_1164.all;

entity ram_pos_ctrl is
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
    ub_ram_n : out   std_logic;         --Velger ut h�y byte (MSB)

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
end ram_pos_ctrl;

