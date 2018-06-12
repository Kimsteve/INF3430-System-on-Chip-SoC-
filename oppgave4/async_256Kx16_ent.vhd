
--************************************************************************
--**    MODEL   :       async_32Kx16.vhd                                **
--**    COMPANY :       Cypress Semiconductor                           **
--**    REVISION:       1.0 Created new base model                      ** 
--************************************************************************

library IEEE, work;
use IEEE.Std_Logic_1164.all;

------------------------
-- Entity Description
------------------------

entity async_256kx16 is
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
end async_256kx16;

-----------------------------
-- End Entity Description
-----------------------------
