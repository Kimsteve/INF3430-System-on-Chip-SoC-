--************************************************************************
--**    MODEL   :       package_timing.vhd                              **
--**    COMPANY :       Cypress Semiconductor                           **
--**    REVISION:       1.0 (Created new timing package model)          ** 
--************************************************************************


library IEEE, std;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use std.textio.all;

--****************************************************************

package timing_pkg is

------------------------------------------------------------------------------------------------
-- Read Cycle timing
------------------------------------------------------------------------------------------------
  constant tRC   : time := 10 ns;       --   Read Cycle Time     
  constant tAA   : time := 10 ns;       --   Address to Data Valid
  constant tOHA  : time := 2 ns;        --   Data Hold from Address Change
  constant tACE  : time := 10 ns;  --   Random access CEb Low to Data Valid
  constant tDOE  : time := 4 ns;        --   OE Low to Data Valid
  constant tLZOE : time := 0 ns;        --   OE Low to LOW Z
  constant tHZOE : time := 4 ns;        --   OE High to HIGH Z
  constant tLZCE : time := 3 ns;        --   CEb LOW to LOW Z
  constant tHZCE : time := 4 ns;        --   CEb HIGH to HIGH Z

  constant tDBE  : time := 4 ns;        --   nLB/nUB LOW to Data Valid
  constant tLZBE : time := 0 ns;        --   nLB/nUB LOW to LOW Z
  constant tHZBE : time := 3 ns;        --   nLB/nUB HIGH to HIGH Z

------------------------------------------------------------------------------------------------
-- Write Cycle timing
------------------------------------------------------------------------------------------------
  constant tWC  : time := 10 ns;        --   Write Cycle Time
  constant tSCE : time := 8 ns;         --   CEb LOW to Write End

  constant tAW : time := 8 ns;          --   Address Setup to Write End
  constant tSA : time := 0 ns;          --   Address Setup to Write Start
  constant tHA : time := 0 ns;          --   Address Hold from Write End

  constant tPWE : time := 8 ns;         --   nWE pulse width

  constant tSD : time := 6 ns;          --   Data Setup to Write End 
  constant tHD : time := 0 ns;          --   Data Hold from Write End

  constant tBW : time := 6 ns;          --   nLB/nUB Setup to Write End

  constant tLZWE : time := 2 ns;        --   nWE Low to High Z
  constant tHZWE : time := 5 ns;        --   nWE High to Low Z

end timing_pkg;


package body timing_pkg is

end timing_pkg;















