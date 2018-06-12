library IEEE;
use IEEE.std_logic_1164.all;

entity ram_sp is
  
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
end ram_sp;
