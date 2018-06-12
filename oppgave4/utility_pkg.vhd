--****************************************************************
--**    MODEL   :     package_utility                           **
--**    COMPANY :     Cypress Semiconductor     **
--**    REVISION:     1.0 Created new package utility model     **
--**                                                            **
--****************************************************************
library ieee, work;
use ieee.std_logic_1164.all;
use IEEE.Std_Logic_Arith.all;
use IEEE.std_logic_TextIO.all;

library Std;
use STD.TextIO.all;

package utility_pkg is

  function convert_string(S : in string) return std_logic_vector;
  function conv_integer1(S  :    std_logic_vector) return integer;

end utility_pkg;

package body utility_pkg is


------------------------------------------------------------------------------------------------
--Converts string into std_logic_vector 
------------------------------------------------------------------------------------------------

  function convert_string(S : in string) return std_logic_vector is
    variable result : std_logic_vector(S'range);
  begin
    for i in S'range loop
      if S(i) = '0' then
        result(i) := '0';
      elsif S(i) = '1' then
        result(i) := '1';
      elsif S(i) = 'X' then
        result(i) := 'X';
      else
        result(i) := 'Z';
      end if;
    end loop;
    return result;
  end convert_string;

------------------------------------------------------------------------------------------------
--Converts std_logic_vector into integer
------------------------------------------------------------------------------------------------

  function conv_integer1(S : std_logic_vector) return integer is
    variable result : integer := 0;
  begin
    for i in S'range loop
      if S(i) = '1' then
        result := result + (2**i);
      elsif S(i) = '0' then
        result := result;
      else
        result := 0;
      end if;
    end loop;
    return result;
  end conv_integer1;

end utility_pkg;


