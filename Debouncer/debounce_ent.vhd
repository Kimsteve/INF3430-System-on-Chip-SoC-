library IEEE;
use IEEE.std_logic_1164.all;

entity debouncer is
  generic (
    cwidth : natural := 2
    -- cwidth prellbskyttelse varighet = 2**(cwidth-1)/(50*10**6)
    --    2       0.04 us
    --    4       0.16 us
    --    8       2.56 us
    --   16       0.66 ms
    --   20      10.48 ms
    --   24       0.167 s
    --   26       0.671 s
    );
  port (
    rst       : in  std_logic;
    clk       : in  std_logic;
    bounced   : in  std_logic;
    debounced : out std_logic
    );
end;
